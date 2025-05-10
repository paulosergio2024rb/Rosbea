<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Detalhes do Pedido e Pagamentos</title>
</head>
<body>
    <h1>Detalhes do Pedido e Pagamentos</h1>

    <%
    String nrPedidoBusca = request.getParameter("nr_pedido");

    if (nrPedidoBusca != null && !nrPedidoBusca.isEmpty()) {
        String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
        String dbUser = "paulo";
        String dbPassword = "6421";
        Connection connection = null;
        PreparedStatement preparedStatementDetalhesPedido = null;
        ResultSet resultSetDetalhesPedido = null;
        PreparedStatement preparedStatementVencimentos = null;
        ResultSet resultSetVencimentos = null;

        try {
            Class.forName("org.mariadb.jdbc.Driver");
            connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            // Busca detalhes do pedido (apenas para exibição geral)
            String sqlDetalhesPedido = "SELECT * FROM vw_detalhes_impressao_pedido WHERE pedido_id = ?";
            preparedStatementDetalhesPedido = connection.prepareStatement(sqlDetalhesPedido);
            preparedStatementDetalhesPedido.setString(1, nrPedidoBusca);
            resultSetDetalhesPedido = preparedStatementDetalhesPedido.executeQuery();

            if (resultSetDetalhesPedido.next()) {
                %>
                <h2>Detalhes do Pedido</h2>
                <table>
                    <tr><th>Cliente RG</th><td><%= resultSetDetalhesPedido.getString("cliente_rg") %></td></tr>
                    <tr><th>Nome do Cliente</th><td><%= resultSetDetalhesPedido.getString("nome_do_cliente") %></td></tr>
                    </table>

                <h2>Vencimentos Pendentes</h2>
                <form action="processar_pagamentos_pedido.jsp" method="post">
                    <input type="hidden" name="nr_pedido" value="<%= nrPedidoBusca %>">
                    <table>
                        <thead>
                            <tr>
                                <th>ID Vencimento</th>
                                <th>Data Vencimento</th>
                                <th>Valor Vencimento</th>
                                <th>Valor Pago</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            // Busca todos os vencimentos para o nr_pedido
                            String sqlVencimentos = "SELECT id, data_pedidovcto, valor_ped, pgto FROM vencimentos WHERE nr_pedido = ?";
                            preparedStatementVencimentos = connection.prepareStatement(sqlVencimentos);
                            preparedStatementVencimentos.setString(1, nrPedidoBusca);
                            resultSetVencimentos = preparedStatementVencimentos.executeQuery();

                            while (resultSetVencimentos.next()) {
                                int idVencimento = resultSetVencimentos.getInt("id");
                                java.sql.Date dataVencimento = resultSetVencimentos.getDate("data_pedidovcto");
                                double valorVencimento = resultSetVencimentos.getDouble("valor_ped");
                                double valorPagoVencimento = resultSetVencimentos.getDouble("pgto");
                                %>
                                <tr>
                                    <td><%= idVencimento %></td>
                                    <td><%= dataVencimento %></td>
                                    <td><%= valorVencimento %></td>
                                    <td><input type="number" name="pgto_<%= idVencimento %>" step="0.01" value="<%= valorPagoVencimento %>"></td>
                                </tr>
                                <%
                            }
                            %>
                        </tbody>
                    </table>
                    <br>
                    <button type="submit">Salvar Pagamentos</button>
                </form>
                <%
            } else {
                out.println("<p>Pedido não encontrado com o número: " + nrPedidoBusca + "</p>");
            }

        } catch (ClassNotFoundException e) {
            out.println("<p>Erro: Driver do MariaDB não encontrado.</p>");
            e.printStackTrace();
        } catch (SQLException e) {
            out.println("<p>Erro de SQL: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            try {
                if (resultSetDetalhesPedido != null) resultSetDetalhesPedido.close();
                if (preparedStatementDetalhesPedido != null) preparedStatementDetalhesPedido.close();
                if (resultSetVencimentos != null) resultSetVencimentos.close();
                if (preparedStatementVencimentos != null) preparedStatementVencimentos.close();
                if (connection != null) connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        out.println("<p>Por favor, insira o número do pedido para buscar.</p>");
    }
    %>
    <br>
    <a href="buscar_pedido.jsp">Voltar para a Busca</a>
</body>
</html>