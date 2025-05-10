<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Resumo de Pedidos Completo</title>
        <style>
            body {
                font-family: 'Roboto', sans-serif;
                margin: 0;
                padding: 20px;
                background-color: #f5f5f5;
            }
            .container {
                max-width: 1200px;
                margin: 0 auto;
                background: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
            }
            h1 {
                color: #333;
                text-align: center;
            }
            .search-form {
                background: #f9f9f9;
                padding: 20px;
                border-radius: 5px;
                margin-bottom: 20px;
            }
            .filter-section {
                display: flex;
                flex-wrap: wrap;
                gap: 15px;
                margin-bottom: 15px;
            }
            .form-group {
                flex: 1;
                min-width: 200px;
            }
            label {
                display: block;
                margin-bottom: 5px;
                font-weight: 500;
            }
            input[type="text"],
            input[type="date"],
            input[type="number"] {
                width: 100%;
                padding: 8px;
                border: 1px solid #ddd;
                border-radius: 4px;
                box-sizing: border-box;
            }
            .form-actions {
                text-align: right;
                margin-top: 15px;
            }
            button, .btn-clear {
                padding: 8px 15px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 14px;
            }
            button {
                background-color: #4CAF50;
                color: white;
            }
            .btn-clear {
                background-color: #f44336;
                color: white;
                margin-left: 10px;
                text-decoration: none;
                display: inline-block;
            }
            .styled-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
            }
            .styled-table th, .styled-table td {
                padding: 12px 15px;
                border: 1px solid #ddd;
                text-align: left;
            }
            .styled-table th {
                background-color: #f2f2f2;
                font-weight: 500;
            }
            .currency {
                text-align: right;
            }
            .highlight {
                font-weight: bold;
                color: #0066cc;
            }
            .no-results {
                text-align: center;
                padding: 20px;
                color: #666;
            }
            .total-row {
                background-color: #f5f5f5;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Resumo de Pedidos Completo</h1>

            <form method="get" action="resumo_pedidos.jsp" class="search-form">
                <div class="filter-section">
                    <div class="form-group">
                        <label for="pedido_id">Nº Pedido:</label>
                        <input type="text" id="pedido_id" name="pedido_id" 
                               value="<%= request.getParameter("pedido_id") != null ? request.getParameter("pedido_id") : ""%>">
                    </div>

                    <div class="form-group">
                        <label for="cliente_id">RG Cliente:</label>
                        <input type="text" id="cliente_id" name="cliente_id" 
                               value="<%= request.getParameter("cliente_id") != null ? request.getParameter("cliente_id") : ""%>">
                    </div>

                    <div class="form-group">
                        <label for="nome_cliente">Nome Cliente:</label>
                        <input type="text" id="nome_cliente" name="nome_cliente" 
                               value="<%= request.getParameter("nome_cliente") != null ? request.getParameter("nome_cliente") : ""%>">
                    </div>
                </div>

                <div class="filter-section">
                    <div class="form-group">
                        <label for="data_inicio">Data Início:</label>
                        <input type="date" id="data_inicio" name="data_inicio"
                               value="<%= request.getParameter("data_inicio") != null ? request.getParameter("data_inicio") : ""%>">
                    </div>

                    <div class="form-group">
                        <label for="data_fim">Data Fim:</label>
                        <input type="date" id="data_fim" name="data_fim"
                               value="<%= request.getParameter("data_fim") != null ? request.getParameter("data_fim") : ""%>">
                    </div>

                    <div class="form-group">
                        <label for="valor_min">Valor Mínimo:</label>
                        <input type="number" id="valor_min" name="valor_min" step="0.01"
                               value="<%= request.getParameter("valor_min") != null ? request.getParameter("valor_min") : ""%>">
                    </div>

                    <div class="form-group">
                        <label for="valor_max">Valor Máximo:</label>
                        <input type="number" id="valor_max" name="valor_max" step="0.01"
                               value="<%= request.getParameter("valor_max") != null ? request.getParameter("valor_max") : ""%>">
                    </div>
                </div>
                    
                <div class="form-actions">
                    <button type="submit">Buscar</button>
                    <a href="caixa.jsp" class="btn-clear" style="background-color: #2196F3;">Voltar ao Caixa</a>
                    <a href="resumo_pedidos.jsp" class="btn-clear">Limpar</a>
                </div>
            </form>

            <%
                String jdbcURL = "jdbc:mariadb://localhost:3306/Rosbea";
                String dbUser = "paulo";
                String dbPassword = "6421";

                Connection connection = null;
                Statement statement = null;
                ResultSet resultSet = null;

                double totalGeralPgto = 0;
                double totalGeralDesconto = 0;
                double totalGeralParcela = 0;
                double totalGeralFinal = 0;
                int totalPedidos = 0;

                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    connection = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
                    statement = connection.createStatement();

                    // Construir query SQL
                    StringBuilder sql = new StringBuilder(
                            "SELECT nr_pedido, cliente_id, nome_do_cliente, total_pgto, total_desconto, "
                            + "total_valor_parcela, total_geral, vencto FROM resumo_pedidos WHERE 1=1");

                    // Aplicar filtros
                    String pedidoId = request.getParameter("pedido_id");
                    if (pedidoId != null && !pedidoId.isEmpty()) {
                        sql.append(" AND nr_pedido = '").append(pedidoId).append("'");
                    }

                    String clienteId = request.getParameter("cliente_id");
                    if (clienteId != null && !clienteId.isEmpty()) {
                        sql.append(" AND cliente_id = '").append(clienteId).append("'");
                    }

                    String nomeCliente = request.getParameter("nome_cliente");
                    if (nomeCliente != null && !nomeCliente.isEmpty()) {
                        sql.append(" AND nome_do_cliente LIKE '%").append(nomeCliente).append("%'");
                    }

                    String dataInicio = request.getParameter("data_inicio");
                    if (dataInicio != null && !dataInicio.isEmpty()) {
                        sql.append(" AND vencto >= '").append(dataInicio).append("'");
                    }

                    String dataFim = request.getParameter("data_fim");
                    if (dataFim != null && !dataFim.isEmpty()) {
                        sql.append(" AND vencto <= '").append(dataFim).append(" 23:59:59'");
                    }

                    String valorMin = request.getParameter("valor_min");
                    if (valorMin != null && !valorMin.isEmpty()) {
                        sql.append(" AND total_geral >= ").append(valorMin);
                    }

                    String valorMax = request.getParameter("valor_max");
                    if (valorMax != null && !valorMax.isEmpty()) {
                        sql.append(" AND total_geral <= ").append(valorMax);
                    }

                    sql.append(" ORDER BY nr_pedido DESC");

                    // Executar consulta
                    resultSet = statement.executeQuery(sql.toString());
            %>

            <table class="styled-table">
                <thead>
                    <tr>
                        <th>Nº Pedido</th>
                        <th>RG Cliente</th>
                        <th>Cliente</th>
                        <th>Data Vencimento</th>
                        <th>Total Pago</th>
                        <th>Desconto</th>
                        <th>Valor Parcelas</th>
                        <th>Total Geral</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        boolean hasResults = false;
                        while (resultSet.next()) {
                            hasResults = true;
                            totalPedidos++;

                            String dataVencimento = resultSet.getString("vencto");
                            String dataFormatada = (dataVencimento != null && dataVencimento.length() >= 10)
                                    ? dataVencimento.substring(0, 10) : "";

                            double pgto = resultSet.getDouble("total_pgto");
                            double desconto = resultSet.getDouble("total_desconto");
                            double parcela = resultSet.getDouble("total_valor_parcela");
                            double geral = resultSet.getDouble("total_geral");

                            totalGeralPgto += pgto;
                            totalGeralDesconto += desconto;
                            totalGeralParcela += parcela;
                            totalGeralFinal += geral;
                    %>
                    <tr>
                        <td><%= resultSet.getString("nr_pedido")%></td>
                        <td><%= resultSet.getString("cliente_id")%></td>
                        <td><%= resultSet.getString("nome_do_cliente")%></td>
                        <td><%= dataFormatada%></td>
                        <td class="currency">R$ <%= String.format("%.2f", pgto)%></td>
                        <td class="currency">R$ <%= String.format("%.2f", desconto)%></td>
                        <td class="currency">R$ <%= String.format("%.2f", parcela)%></td>
                        <td class="currency highlight">R$ <%= String.format("%.2f", geral)%></td>
                    </tr>
                    <% }
                        if (!hasResults) {
                    %>
                    <tr>
                        <td colspan="8" class="no-results">Nenhum pedido encontrado com os filtros aplicados</td>
                    </tr>
                    <% } %>
                </tbody>

                <% if (hasResults) {%>
                <tfoot>
                    <tr class="total-row">
                        <td colspan="3">Total Geral (<%= totalPedidos%> pedidos)</td>
                        <td></td>
                        <td class="currency">R$ <%= String.format("%.2f", totalGeralPgto)%></td>
                        <td class="currency">R$ <%= String.format("%.2f", totalGeralDesconto)%></td>
                        <td class="currency">R$ <%= String.format("%.2f", totalGeralParcela)%></td>
                        <td class="currency highlight">R$ <%= String.format("%.2f", totalGeralFinal)%></td>
                    </tr>
                </tfoot>
                <% } %>
            </table>

            <%
                } catch (ClassNotFoundException e) {
                    out.println("<div class='error-message'>Erro ao carregar o driver JDBC: " + e.getMessage() + "</div>");
                } catch (SQLException e) {
                    out.println("<div class='error-message'>Erro no banco de dados: " + e.getMessage() + "</div>");
                } finally {
                    if (resultSet != null) try {
                        resultSet.close();
                    } catch (SQLException e) {
                    }
                    if (statement != null) try {
                        statement.close();
                    } catch (SQLException e) {
                    }
                    if (connection != null) try {
                        connection.close();
                    } catch (SQLException e) {
                    }
                }
            %>
        </div>
    </body>
</html>