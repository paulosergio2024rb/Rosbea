<%@ page import="java.util.Date" %>
<%@page import="java.sql.Connection"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Configurações do MariaDB
    String dbUrl = "jdbc:mariadb://localhost:3306/Rosbea";
    String dbUser = "paulo";
    String dbPassword = "6421";

    Connection conexao = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // Parâmetros do formulário
    String dataInicio = request.getParameter("dataInicio");
    String dataFim = request.getParameter("dataFim");
    String ordenacao = request.getParameter("ordenacao");
    String produtoSelecionado = request.getParameter("produto");
    String clienteSelecionado = request.getParameter("cliente");

    // Valores padrão para os filtros (últimos 30 dias)
    if (dataInicio == null || dataInicio.isEmpty()) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -1);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        dataInicio = sdf.format(cal.getTime());
        dataFim = sdf.format(new java.util.Date());
    }
    if (produtoSelecionado == null) {
        produtoSelecionado = "";
    }
    if (clienteSelecionado == null)
        clienteSelecionado = "";
%>

<!DOCTYPE html>
<html>
    <head>
        <a href="relatorios.html"></i> Voltar</a> 
        <title>Relatório de Vendas - Rosbea</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                margin: 0;
                padding: 20px;
                background: #f8f9fa;
                color: #333;
            }
            .container {
                background: white;
                padding: 25px;
                border-radius: 10px;
                box-shadow: 0 0 15px rgba(0,0,0,0.05);
                max-width: 1200px;
                margin: 0 auto;
            }
            h1 {
                color: #2c3e50;
                margin-bottom: 25px;
                font-size: 24px;
                border-bottom: 2px solid #4CAF50;
                padding-bottom: 10px;
            }
            .filter-panel {
                background: #f1f8fe;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 25px;
                border: 1px solid #d1e3f6;
            }
            .form-row {
                display: flex;
                flex-wrap: wrap;
                gap: 20px;
                margin-bottom: 15px;
            }
            .form-group {
                flex: 1;
                min-width: 200px;
            }
            label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: #2c3e50;
                font-size: 14px;
            }
            select, input[type="date"] {
                width: 100%;
                padding: 10px;
                border: 1px solid #ddd;
                border-radius: 6px;
                background: white;
                font-size: 14px;
                transition: border-color 0.3s;
            }
            select:focus, input[type="date"]:focus {
                border-color: #4CAF50;
                outline: none;
            }
            .button-group {
                display: flex;
                gap: 10px;
                margin-top: 15px;
                flex-wrap: wrap;
            }
            button {
                padding: 10px 20px;
                border-radius: 6px;
                border: none;
                font-weight: 600;
                cursor: pointer;
                transition: background-color 0.3s;
                font-size: 14px;
            }
            .filter-btn {
                background-color: #4CAF50;
                color: white;
            }
            .filter-btn:hover {
                background-color: #3d8b40;
            }
            .export-btn {
                background-color: #2196F3;
                color: white;
            }
            .export-btn:hover {
                background-color: #0b7dda;
            }
            .summary-cards {
                display: flex;
                gap: 20px;
                margin: 25px 0;
                flex-wrap: wrap;
            }
            .card {
                background: white;
                border-radius: 8px;
                padding: 20px;
                flex: 1;
                min-width: 200px;
                box-shadow: 0 3px 10px rgba(0,0,0,0.08);
                border: 1px solid #eaeaea;
            }
            .card h3 {
                margin: 0 0 12px 0;
                color: #555;
                font-size: 15px;
                font-weight: 600;
            }
            .card-value {
                font-size: 20px;
                font-weight: bold;
                color: #2c3e50;
            }
            .money {
                color: #4CAF50;
            }
            .report-title {
                color: #2c3e50;
                font-size: 20px;
                margin: 30px 0 15px 0;
                padding-bottom: 10px;
                border-bottom: 2px solid #eaeaea;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
                font-size: 14px;
                box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            }
            th {
                background-color: #4CAF50;
                color: white;
                padding: 12px 15px;
                text-align: left;
                font-weight: 600;
            }
            td {
                padding: 12px 15px;
                border-bottom: 1px solid #eaeaea;
            }
            tr:nth-child(even) {
                background-color: #f9f9f9;
            }
            tr:hover {
                background-color: #f1f8fe;
            }
            .total-row td {
                font-weight: bold;
                background-color: #e8f5e9;
            }
            .error {
                color: #e74c3c;
                font-weight: bold;
                padding: 15px;
                background: #fdecea;
                border-radius: 6px;
                margin: 20px 0;
            }
            @media (max-width: 768px) {
                .card {
                    min-width: calc(50% - 20px);
                }
                .form-group {
                    min-width: 100%;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Relatório de Vendas - Rosbea</h1>

            <!-- Painel de Filtros -->
            <div class="filter-panel">
                <form method="get" action="relatorio_vendas.jsp">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="dataInicio">Data Início</label>
                            <input type="date" id="dataInicio" name="dataInicio" value="<%= dataInicio%>" required>
                        </div>

                        <div class="form-group">
                            <label for="dataFim">Data Fim</label>
                            <input type="date" id="dataFim" name="dataFim" value="<%= dataFim%>" required>
                        </div>

                        <div class="form-group">
                            <label for="produto">Produto</label>
                            <select id="produto" name="produto">
                                <option value="">Todos os Produtos</option>
                                <%
                                    try {
                                        Class.forName("org.mariadb.jdbc.Driver");
                                        conexao = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
                                        ps = conexao.prepareStatement("SELECT DISTINCT produto_id, nome_produto FROM vw_relatorio_vendas_periodo ORDER BY nome_produto");
                                        rs = ps.executeQuery();

                                        while (rs.next()) {
                                            String id = rs.getString("produto_id");
                                            String nome = rs.getString("nome_produto");
                                %>
                                <option value="<%= id%>" <%= id.equals(produtoSelecionado) ? "selected" : ""%>>
                                    <%= nome%>
                                </option>
                                <%
                                        }
                                    } catch (SQLException e) {
                                        out.println("<span class='error'>Erro ao carregar produtos: " + e.getMessage() + "</span>");
                                    } finally {
                                        if (rs != null) {
                                            rs.close();
                                        }
                                        if (ps != null) {
                                            ps.close();
                                        }
                                        if (conexao != null) {
                                            conexao.close();
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="cliente">Cliente</label>
                            <select id="cliente" name="cliente">
                                <option value="">Todos os Clientes</option>
                                <%
                                    try {
                                        Class.forName("org.mariadb.jdbc.Driver");
                                        conexao = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

                                        // Busca clientes com vendas no período selecionado
                                        String sqlClientes = "SELECT DISTINCT rg, nome_cliente FROM vw_relatorio_vendas_periodo "
                                                + "WHERE data BETWEEN ? AND ? "
                                                + "ORDER BY nome_cliente";

                                        ps = conexao.prepareStatement(sqlClientes);
                                        ps.setString(1, dataInicio);
                                        ps.setString(2, dataFim);
                                        rs = ps.executeQuery();

                                        while (rs.next()) {
                                            String rg = rs.getString("rg");
                                            String nome = rs.getString("nome_cliente");
                                %>
                                <option value="<%= rg%>" <%= rg.equals(clienteSelecionado) ? "selected" : ""%>>
                                    <%= nome%>
                                </option>
                                <%
                                        }
                                    } catch (SQLException e) {
                                        out.println("<span class='error'>Erro ao carregar clientes: " + e.getMessage() + "</span>");
                                    } finally {
                                        if (rs != null) {
                                            rs.close();
                                        }
                                        if (ps != null) {
                                            ps.close();
                                        }
                                        if (conexao != null) {
                                            conexao.close();
                                        }
                                    }
                                %>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="ordenacao">Ordenar por</label>
                            <select id="ordenacao" name="ordenacao">
                                <option value="data" <%= "data".equals(ordenacao) ? "selected" : ""%>>Data</option>
                                <option value="valor" <%= "valor".equals(ordenacao) ? "selected" : ""%>>Valor</option>
                                <option value="cliente" <%= "cliente".equals(ordenacao) ? "selected" : ""%>>Cliente</option>
                            </select>
                        </div>
                    </div>

                    <div class="button-group">
                        <button type="submit" class="filter-btn">Aplicar Filtros</button>
                        <button type="button" class="export-btn" onclick="exportToExcel()">Exportar para Excel</button>
                    </div>
                </form>
            </div>

            <!-- Resultados do Relatório -->
            <%
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    conexao = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

                    // Construção da consulta SQL principal
                    String sql = "SELECT data, rg, nome_cliente, produto_id, nome_produto, "
                            + "SUM(total_valor) as valor_total, "
                            + "SUM(total_pedidos) as total_pedidos, "
                            + "SUM(total_quantidade) as quantidade_total, "
                            + "SUM(total_valor)/SUM(total_pedidos) as ticket_medio "
                            + "FROM vw_relatorio_vendas_periodo "
                            + "WHERE data BETWEEN ? AND ? ";

                    if (!produtoSelecionado.isEmpty()) {
                        sql += "AND produto_id = ? ";
                    }

                    if (!clienteSelecionado.isEmpty()) {
                        sql += "AND rg = ? ";
                    }

                    sql += "GROUP BY data, rg, nome_cliente, produto_id, nome_produto";

                    // Ordenação
                    if ("valor".equals(ordenacao)) {
                        sql += " ORDER BY valor_total DESC";
                    } else if ("cliente".equals(ordenacao)) {
                        sql += " ORDER BY nome_cliente, data";
                    } else {
                        sql += " ORDER BY data, nome_cliente";
                    }

                    ps = conexao.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                    ps.setString(1, dataInicio);
                    ps.setString(2, dataFim);

                    int paramIndex = 3;

                    if (!produtoSelecionado.isEmpty()) {
                        ps.setString(paramIndex++, produtoSelecionado);
                    }

                    if (!clienteSelecionado.isEmpty()) {
                        ps.setString(paramIndex, clienteSelecionado);
                    }

                    rs = ps.executeQuery();

                    // Variáveis para totais
                    double totalGeral = 0;
                    int totalPedidos = 0;
                    int totalQuantidade = 0;

                    // Primeira passada para calcular totais
                    while (rs.next()) {
                        totalGeral += rs.getDouble("valor_total");
                        totalPedidos += rs.getInt("total_pedidos");
                        totalQuantidade += rs.getInt("quantidade_total");
                    }

                    // Segunda passada para exibir resultados
                    if (totalGeral > 0) {
                        rs.beforeFirst();
            %>

            <!-- Cartões de Resumo - Layout Otimizado -->
            <div class="summary-cards">
                <div class="card">
                    <h3>Período</h3>
                    <div class="card-value"><%= new SimpleDateFormat("dd/MM/yyyy").format(new SimpleDateFormat("yyyy-MM-dd").parse(dataInicio))%> <br> 
                        <%= new SimpleDateFormat("dd/MM/yyyy").format(new SimpleDateFormat("yyyy-MM-dd").parse(dataFim))%></div>
                </div>
                <div class="card">
                    <h3>Valor Total</h3>
                    <div class="card-value money">R$ <%= String.format("%,.2f", totalGeral)%></div>
                </div>
                <div class="card">
                    <h3>Total Pedidos</h3>
                    <div class="card-value"><%= String.format("%,d", totalPedidos)%></div>
                </div>
                <div class="card">
                    <h3>Quantidade Vendida</h3>
                    <div class="card-value"><%= String.format("%,d", totalQuantidade)%></div>
                </div>
            </div>

            <h2 class="report-title">Detalhes das Vendas</h2>

            <div style="overflow-x: auto;">
                <table border="1" id="reportTable">
                    <thead>
                        <tr>
                            <th>Data</th>
                            <th>RG</th>
                            <th>Cliente</th>
                            <th>Produto</th>
                            <th class="money">Valor Total</th>
                            <th class="number">Pedidos</th>
                            <th class="number">Quantidade</th>
                            <th class="money">Ticket Médio</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% while (rs.next()) {%>
                        <tr>
                            <td><%= new SimpleDateFormat("dd/MM/yyyy").format(new SimpleDateFormat("yyyy-MM-dd").parse(rs.getString("data")))%></td>
                            <td><%= rs.getString("rg")%></td>
                            <td><%= rs.getString("nome_cliente")%></td>
                            <td><%= rs.getString("nome_produto")%></td>
                            <td class="money">R$ <%= String.format("%,.2f", rs.getDouble("valor_total"))%></td>
                            <td class="number"><%= rs.getInt("total_pedidos")%></td>
                            <td class="number"><%= rs.getInt("quantidade_total")%></td>
                            <td class="money">R$ <%= String.format("%,.2f", rs.getDouble("ticket_medio"))%></td>
                        </tr>
                        <% }%>
                        <tr class="total-row">
                            <td colspan="4"><strong>TOTAL GERAL</strong></td>
                            <td class="money"><strong>R$ <%= String.format("%,.2f", totalGeral)%></strong></td>
                            <td class="number"><strong><%= String.format("%,d", totalPedidos)%></strong></td>
                            <td class="number"><strong><%= String.format("%,d", totalQuantidade)%></strong></td>
                            <td class="money"><strong>R$ <%= String.format("%,.2f", totalGeral / totalPedidos)%></strong></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <%
                    } else {
                        out.println("<p class='error'>Nenhum resultado encontrado para os filtros selecionados.</p>");
                    }
                } catch (SQLException e) {
                    out.println("<div class='error'>");
                    out.println("<h3>Erro ao acessar o banco de dados</h3>");
                    out.println("<p><strong>Mensagem:</strong> " + e.getMessage() + "</p>");
                    out.println("<p>Verifique:</p>");
                    out.println("<ul>");
                    out.println("<li>O serviço do MariaDB está rodando</li>");
                    out.println("<li>As credenciais de acesso estão corretas</li>");
                    out.println("<li>O banco de dados 'Rosbea' existe</li>");
                    out.println("<li>O driver mariadb-java-client.jar está na pasta WEB-INF/lib</li>");
                    out.println("</ul>");
                    out.println("</div>");
                } finally {
                    // Fecha conexões
                    try {
                        if (rs != null) {
                            rs.close();
                        }
                    } catch (SQLException e) {
                        /* ignorar */ }
                    try {
                        if (ps != null) {
                            ps.close();
                        }
                    } catch (SQLException e) {
                        /* ignorar */ }
                    try {
                        if (conexao != null) {
                            conexao.close();
                        }
                    } catch (SQLException e) {
                        /* ignorar */ }
                }
            %>
        </div>

        <script>
            function exportToExcel() {
                // Cria um link para download do relatório em formato Excel
                let html = document.getElementById("reportTable").outerHTML;
                let blob = new Blob([html], {type: "application/vnd.ms-excel"});
                let a = document.createElement("a");
                a.href = URL.createObjectURL(blob);

                // Nome do arquivo com data atual
                let today = new Date();
                let dateStr = today.toLocaleDateString('pt-BR').replaceAll('/', '-');
                a.download = "relatorio_vendas_" + dateStr + ".xls";

                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
            }
        </script>
        <a href="index.jsp" class="btn-voltar">
            <i class="fas fa-arrow-left"></i> Voltar ao Início
        </a>
    </body>
</html>