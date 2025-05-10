<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Detalhes do Pedido e Pagamentos</title>
    <style>
        table { border-collapse: collapse; width: 80%; margin-bottom: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        .pago { background-color: #d4edda; } /* fundo verde para pagos */
        .parcial { background-color: #fff3cd; } /* fundo amarelo para pagamentos parciais */
        .nao-pago { background-color: #f8d7da; } /* fundo vermelho para não pagos */
        .valor-pago { color: #28a745; font-weight: bold; }
        .valor-pendente { color: #dc3545; }
        .valor-parcial { color: #ffc107; }
        .status-pago { font-weight: bold; color: #28a745; }
        .status-parcial { font-weight: bold; color: #ffc107; }
        .status-pendente { font-weight: bold; color: #dc3545; }
        input[type="number"] { width: 100px; text-align: right; }
        .mensagem { padding: 10px; margin: 10px 0; border-radius: 4px; }
        .sucesso { background-color: #d4edda; color: #155724; }
        .erro { background-color: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <h1>Detalhes do Pedido e Pagamentos</h1>

    <%-- Exibir mensagens de sucesso/erro --%>
    <%
    String mensagem = request.getParameter("mensagem");
    String tipoMensagem = request.getParameter("tipoMensagem");
    if (mensagem != null && !mensagem.isEmpty()) {
    %>
        <div class="mensagem <%= tipoMensagem != null ? tipoMensagem : "" %>">
            <%= mensagem %>
        </div>
    <%
    }
    %>

<%
String nrPedidoBusca = request.getParameter("nr_pedido");

if (nrPedidoBusca != null && !nrPedidoBusca.isEmpty()) {
    String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
    String dbUser = "paulo";
    String dbPassword = "6421";
    Connection connection = null;
    PreparedStatement psDetalhes = null;
    PreparedStatement psVencimentos = null;
    PreparedStatement psTotalPago = null;
    ResultSet rsDetalhes = null;
    ResultSet rsVencimentos = null;
    ResultSet rsTotalPago = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

        // Detalhes do pedido
        String sqlDetalhes = "SELECT * FROM vw_detalhes_impressao_pedido WHERE pedido_id = ?";
        psDetalhes = connection.prepareStatement(sqlDetalhes);
        psDetalhes.setString(1, nrPedidoBusca);
        rsDetalhes = psDetalhes.executeQuery();

        // Calcular total pago no pedido
        double totalPagoPedido = 0;
        String sqlTotalPago = "SELECT COALESCE(SUM(pgto), 0) AS total_pago FROM vencimentos WHERE nr_pedido = ?";
        psTotalPago = connection.prepareStatement(sqlTotalPago);
        psTotalPago.setString(1, nrPedidoBusca);
        rsTotalPago = psTotalPago.executeQuery();
        if (rsTotalPago.next()) {
            totalPagoPedido = rsTotalPago.getDouble("total_pago");
        }

        if (rsDetalhes.next()) {
            double valorTotalPedido = rsDetalhes.getDouble("valor_total");
%>
        <h2>Detalhes do Pedido</h2>
        <table>
            <tr><th>Número do Pedido</th><td><%= nrPedidoBusca %></td></tr>
            <tr><th>Cliente RG</th><td><%= rsDetalhes.getString("cliente_rg") %></td></tr>
            <tr><th>Nome do Cliente</th><td><%= rsDetalhes.getString("nome_do_cliente") %></td></tr>
            <tr><th>Total do Pedido</th><td>R$ <%= String.format("%.2f", valorTotalPedido) %></td></tr>
            <tr><th>Total Pago</th><td>R$ <%= String.format("%.2f", totalPagoPedido) %></td></tr>
            <tr><th>Saldo Devedor</th><td>R$ <%= String.format("%.2f", (valorTotalPedido - totalPagoPedido)) %></td></tr>
        </table>

        <h2>Parcelas do Pedido</h2>
        <form action="processar_pagamentos_pedido.jsp" method="post" onsubmit="return validarPagamentos()">
            <input type="hidden" name="nr_pedido" value="<%= nrPedidoBusca %>">
            <table>
                <thead>
                    <tr>
                        <th>Parcela</th>
                        <th>Data de Vencimento</th>
                        <th>Valor</th>
                        <th>Situação</th>
                        <th>Valor Pago</th>
                        <th>Saldo</th>
                        <th>Valor a Pagar</th>
                    </tr>
                </thead>
                <tbody>
<%
            String sqlVencimentos = "SELECT id, data_pedidovcto, valor_ped, pgto FROM vencimentos WHERE nr_pedido = ? ORDER BY data_pedidovcto";
            psVencimentos = connection.prepareStatement(sqlVencimentos);
            psVencimentos.setString(1, nrPedidoBusca);
            rsVencimentos = psVencimentos.executeQuery();

            while (rsVencimentos.next()) {
                int id = rsVencimentos.getInt("id");
                Date data = rsVencimentos.getDate("data_pedidovcto");
                double valor = rsVencimentos.getDouble("valor_ped");
                double pgto = rsVencimentos.getDouble("pgto");
                double saldo = valor - pgto;

                boolean pago = pgto > 0.009;
                boolean totalmentePago = Math.abs(pgto - valor) < 0.01;
                boolean parcialmentePago = pago && !totalmentePago;
                
                String classeLinha = "nao-pago";
                if (totalmentePago) classeLinha = "pago";
                else if (parcialmentePago) classeLinha = "parcial";
%>
                    <tr class="<%= classeLinha %>">
                        <td><%= id %></td>
                        <td><%= data %></td>
                        <td>R$ <%= String.format("%.2f", valor) %></td>
                        <td class="status-<%= totalmentePago ? "pago" : (parcialmentePago ? "parcial" : "pendente") %>">
                            <%= totalmentePago ? "Pago" : (parcialmentePago ? "Parcial" : "Pendente") %>
                        </td>
                        <td class="valor-pago">R$ <%= String.format("%.2f", pgto) %></td>
                        <td class="<%= totalmentePago ? "valor-pago" : (parcialmentePago ? "valor-parcial" : "valor-pendente") %>">
                            R$ <%= String.format("%.2f", saldo) %>
                        </td>
                        <td>
                            <% if (!totalmentePago) { %>
                                <input type="number" step="0.01" min="0.01" max="<%= saldo %>" 
                                       name="pgto_<%= id %>" id="pgto_<%= id %>" 
                                       value="<%= saldo %>" 
                                       onchange="validarValor(this, <%= saldo %>)">
                            <% } else { %>
                                <span class="status-pago">Quitado</span>
                            <% } %>
                        </td>
                    </tr>
<%
            }
%>
                </tbody>
            </table>
            <br>
            <button type="submit">Registrar Pagamentos</button>
        </form>
        
        <script>
            function validarValor(input, saldo) {
                if (parseFloat(input.value) > saldo) {
                    alert('O valor informado (' + input.value + ') é maior que o saldo da parcela (' + saldo.toFixed(2) + ')');
                    input.value = saldo.toFixed(2);
                    return false;
                }
                if (parseFloat(input.value) <= 0) {
                    alert('O valor do pagamento deve ser maior que zero');
                    input.value = '0.01';
                    return false;
                }
                return true;
            }
            
            function validarPagamentos() {
                let algumPagamento = false;
                const inputs = document.querySelectorAll('input[type="number"]');
                
                inputs.forEach(input => {
                    if (parseFloat(input.value) > 0) {
                        algumPagamento = true;
                    }
                });
                
                if (!algumPagamento) {
                    alert('Por favor, informe pelo menos um valor de pagamento');
                    return false;
                }
                
                return confirm('Confirma o registro dos pagamentos?');
            }
        </script>
<%
        } else {
            out.println("<p>Pedido não encontrado com o número: " + nrPedidoBusca + "</p>");
        }

    } catch (Exception e) {
        out.println("<div class='mensagem erro'>Erro ao acessar o banco de dados: " + e.getMessage() + "</div>");
        e.printStackTrace();
    } finally {
        try { if (rsTotalPago != null) rsTotalPago.close(); } catch (Exception e) {}
        try { if (psTotalPago != null) psTotalPago.close(); } catch (Exception e) {}
        try { if (rsDetalhes != null) rsDetalhes.close(); } catch (Exception e) {}
        try { if (psDetalhes != null) psDetalhes.close(); } catch (Exception e) {}
        try { if (rsVencimentos != null) rsVencimentos.close(); } catch (Exception e) {}
        try { if (psVencimentos != null) psVencimentos.close(); } catch (Exception e) {}
        try { if (connection != null) connection.close(); } catch (Exception e) {}
    }
} else {
    out.println("<p>Por favor, insira o número do pedido para buscar.</p>");
}
%>
    <br><br>
    <a href="buscar_pedido.jsp">Voltar</a>
</body>
</html>