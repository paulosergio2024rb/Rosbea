<%@page import="java.sql.*"%>
<%@page contentType="text/html;charset=UTF-8"%>
<%
    String pedidoId = request.getParameter("pedido_id");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Relatório do Pedido</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        .total { font-weight: bold; font-size: 1.2em; margin-top: 10px; }
        .print-btn { margin-bottom: 20px; }
        @media print {
            .print-btn { display: none; }
        }
    </style>
</head>
<body>

<h2>Relatório do Pedido #<%= pedidoId %></h2>

<!-- Botão para imprimir diretamente na impressora -->
<form action="imprimirPedidoDireto.jsp" method="get">
    <input type="hidden" name="pedido_id" value="<%= pedidoId %>">
    <button type="submit">🖨️ Imprimir Pedido Direto</button>
</form>

<!-- Exibição do relatório do pedido -->
<%
    Connection con = null;
    double total = 0.0;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        PreparedStatement psPedido = con.prepareStatement("SELECT p.data_pedido,data_atende, c.nome_do_cliente FROM pedido p JOIN cadastro_de_clientes c ON p.cliente_id = c.rg WHERE p.id = ?");
        psPedido.setInt(1, Integer.parseInt(pedidoId));
        ResultSet pedidoRs = psPedido.executeQuery();

        if (pedidoRs.next()) {
%>
<p><strong>Cliente:</strong> <%= pedidoRs.getString("nome_do_cliente") %></p>
<p><strong>Data do Pedido:</strong> <%= pedidoRs.getDate("data_pedido") %></p>
<p><strong>Data Atendimento:</strong> <%= pedidoRs.getDate("data_atende") %></p>
<%
        }

        PreparedStatement psItens = con.prepareStatement(
            "SELECT pr.nome, pi.quantidade, pi.preco FROM pedido_item pi " +
            "JOIN produto pr ON pi.produto_id = pr.codigo WHERE pi.pedido_id = ?");
        psItens.setInt(1, Integer.parseInt(pedidoId));
        ResultSet itensRs = psItens.executeQuery();
%>
<table>
    <tr>
        <th>Produto</th>
        <th>Quantidade</th>
        <th>Preço Unitário</th>
        <th>Subtotal</th>
    </tr>
<%
        while (itensRs.next()) {
            String nome = itensRs.getString("nome");
            int qtd = itensRs.getInt("quantidade");
            double preco = itensRs.getDouble("preco");
            double subtotal = qtd * preco;
            total += subtotal;
%>
    <tr>
        <td><%= nome %></td>
        <td><%= qtd %></td>
        <td>R$ <%= String.format("%.2f", preco) %></td>
        <td>R$ <%= String.format("%.2f", subtotal) %></td>
    </tr>
<%
        }
%>
</table>

<p class="total">Total do Pedido: R$ <%= String.format("%.2f", total) %></p>

<%
    } catch (Exception e) {
        out.print("<p style='color:red'>Erro ao carregar relatório: " + e.getMessage() + "</p>");
    } finally {
        if (con != null) con.close();
    }
%>

</body>
</html>
