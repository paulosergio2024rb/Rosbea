<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Buscar e Inserir/Editar Pagamentos</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }

        h1, h2 {
            color: #333;
            text-align: center;
        }

        form {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            text-align: center;
        }

        form div {
            margin-bottom: 15px;
        }

        label {
            display: inline-block;
            width: 150px;
            text-align: left;
            margin-right: 10px;
            font-weight: bold;
        }

        input[type="text"], input[type="number"] {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: 200px;
        }

        button[type="submit"] {
            background-color: #5cb85c;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }

        button[type="submit"]:hover {
            background-color: #4cae4c;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            overflow: hidden;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #f2f2f2;
            font-weight: bold;
        }

        tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        a {
            display: block;
            margin-top: 20px;
            color: #007bff;
            text-decoration: none;
            text-align: center;
        }

        a:hover {
            text-decoration: underline;
        }
        
        .valor-pendente {
            font-weight: bold;
            color: #d9534f;
        }
        
        .valor-pago {
            font-weight: bold;
            color: #5cb85c;
        }
        
        .parcela-quitada {
            background-color: #f0f0f0;
            color: #999;
        }
        
        .parcela-quitada td {
            text-decoration: line-through;
        }
    </style>
</head>
<body>
    <h1>Buscar Pedido</h1>
    <form method="get">
        <div>
            <label for="nr_pedido">Número do Pedido:</label>
            <input type="text" id="nr_pedido" name="nr_pedido" required>
        </div>
        <br>
        <button type="submit">Buscar</button>
    </form>

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

                // Busca detalhes do pedido
                String sqlDetalhesPedido = "SELECT cliente_rg, nome_do_cliente FROM vw_detalhes_impressao_pedido WHERE pedido_id = ?";
                preparedStatementDetalhesPedido = connection.prepareStatement(sqlDetalhesPedido);
                preparedStatementDetalhesPedido.setString(1, nrPedidoBusca);
                resultSetDetalhesPedido = preparedStatementDetalhesPedido.executeQuery();

                if (resultSetDetalhesPedido.next()) {
    %>
    <h2>Detalhes do Pedido</h2>
    <div style="background-color: #e9ecef; padding: 15px; border-radius: 4px; margin-bottom: 20px;">
        <p><strong>Cliente RG:</strong> <%= resultSetDetalhesPedido.getString("cliente_rg")%></p>
        <p><strong>Nome do Cliente:</strong> <%= resultSetDetalhesPedido.getString("nome_do_cliente")%></p>
    </div>

    <h2>Histórico de Parcelas</h2>
    <form action="processar_pagamentos_pedido.jsp" method="post">
        <input type="hidden" name="nr_pedido" value="<%= nrPedidoBusca%>">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Data Vencimento</th>
                    <th>Valor Total</th>
                    <th>Desconto</th>
                    <th>Valor Pago</th>
                    <th>Valor Pendente</th>
                    <th>Novo Pagamento</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    // Busca TODOS os vencimentos para o nr_pedido
                    String sqlVencimentos = "SELECT id, data_pedidovcto, valor_parcela, pgto, desconto FROM vencimentos WHERE nr_pedido = ? ORDER BY data_pedidovcto";
                    preparedStatementVencimentos = connection.prepareStatement(sqlVencimentos);
                    preparedStatementVencimentos.setString(1, nrPedidoBusca);
                    resultSetVencimentos = preparedStatementVencimentos.executeQuery();

                    while (resultSetVencimentos.next()) {
                        int idVencimento = resultSetVencimentos.getInt("id");
                        java.sql.Date dataVencimento = resultSetVencimentos.getDate("data_pedidovcto");
                        double valorTotal = resultSetVencimentos.getDouble("valor_parcela");
                        double valorPago = resultSetVencimentos.getDouble("pgto");
                        double desconto = resultSetVencimentos.getDouble("desconto");
                        double valorPendente = valorTotal - valorPago - desconto;
                        boolean quitado = (valorPendente <= 0);
                %>
                <tr class="<%= quitado ? "parcela-quitada" : "" %>">
                    <td><%= idVencimento%></td>
                    <td><%= dataVencimento%></td>
                    <td>R$ <%= String.format("%.2f", valorTotal)%></td>
                    <td>R$ <%= String.format("%.2f", desconto)%></td>
                    <td class="valor-pago">R$ <%= String.format("%.2f", valorPago)%></td>
                    <td class="<%= quitado ? "" : "valor-pendente" %>">
                        <%= quitado ? "R$ 0,00" : "R$ " + String.format("%.2f", valorPendente) %>
                    </td>
                    <td>
                        <% if (!quitado) { %>
                            <input type="number" name="pgto_<%= idVencimento%>" 
                                   step="0.01" min="0" max="<%= valorPendente%>" 
                                   value="0" style="width: 100px;">
                        <% } else { %>
                            <span style="color: #5cb85c;">Quitado</span>
                        <% } %>
                    </td>
                    <td>
                        <%= quitado ? "<span style='color: #5cb85c;'>Quitado</span>" : "<span style='color: #d9534f;'>Pendente</span>" %>
                    </td>
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
                    out.println("<p style='text-align: center; margin-top: 20px;'>Pedido não encontrado com o número: " + nrPedidoBusca + "</p>");
                }

            } catch (ClassNotFoundException e) {
                out.println("<p style='color: red;'>Erro: Driver do MariaDB não encontrado.</p>");
                e.printStackTrace();
            } catch (SQLException e) {
                out.println("<p style='color: red;'>Erro de SQL: " + e.getMessage() + "</p>");
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
        }
    %>
    <br>
    <a href="caixa.jsp">Voltar ao Caixa</a>
</body>
</html>