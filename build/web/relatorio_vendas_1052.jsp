<%@ page import="java.util.Date" %>
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

    // Valores padrão para os filtros
    if (dataInicio == null || dataInicio.isEmpty()) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -1);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        dataInicio = sdf.format(cal.getTime());
        dataFim = sdf.format(new java.util.Date());
    }
    if (produtoSelecionado == null) produtoSelecionado = "";
    if (clienteSelecionado == null) clienteSelecionado = "";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Relatório de Vendas - Rosbea</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); max-width: 1200px; margin: 0 auto; }
        .filter-panel { background: #f9f9f9; padding: 15px; border-radius: 5px; margin-bottom: 20px; border: 1px solid #ddd; }
        .form-group { margin-bottom: 15px; display: flex; align-items: center; }
        label { display: inline-block; width: 120px; font-weight: bold; margin-right: 10px; }
        select, input[type="date"], input[type="text"] { padding: 8px; width: 200px; border: 1px solid #ddd; border-radius: 4px; }
        button { padding: 10px 15px; background-color: #4CAF50; color: white; border: none; border-radius: 4px; cursor: pointer; margin-right: 10px; }
        button:hover { background-color: #45a049; }
        .export-btn { background-color: #2196F3; }
        .export-btn:hover { background-color: #0b7dda; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; font-size: 14px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #4CAF50; color: white; position: sticky; top: 0; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .money { text-align: right; }
        .number { text-align: center; }
        .total-row { font-weight: bold; background-color: #e7f3e7 !important; }
        .report-title { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 5px; margin-top: 30px; }
        .error { color: red; font-weight: bold; }
        .summary-cards { display: flex; justify-content: space-between; margin: 20px 0; }
        .card { background: white; border-radius: 5px; padding: 15px; width: 23%; box-shadow: 0 0 5px rgba(0,0,0,0.1); text-align: center; }
        .card h3 { margin-top: 0; color: #555; }
        .card-value { font-size: 24px; font-weight: bold; color: #4CAF50; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Relatório de Vendas - Rosbea</h1>
        
        <!-- Painel de Filtros -->
        <div class="filter-panel">
            <form method="get" action="relatorio_vendas.jsp">
                <div class="form-group">
                    <label for="dataInicio">Data Início:</label>
                    <input type="date" id="dataInicio" name="dataInicio" value="<%= dataInicio %>" required>
                </div>
                
                <div class="form-group">
                    <label for="dataFim">Data Fim:</label>
                    <input type="date" id="dataFim" name="dataFim" value="<%= dataFim %>" required>
                </div>
                
                <div class="form-group">
                    <label for="produto">Produto:</label>
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
                                <option value="<%= id %>" <%= id.equals(produtoSelecionado) ? "selected" : "" %>>
                                    <%= nome %>
                                </option>
                        <%
                            }
                        } catch (SQLException e) {
                            out.println("<span class='error'>Erro ao carregar produtos: " + e.getMessage() + "</span>");
                        } finally {
                            if (rs != null) rs.close();
                            if (ps != null) ps.close();
                            if (conexao != null) conexao.close();
                        }
                        %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="cliente">Cliente:</label>
                    <input type="text" id="cliente" name="cliente" value="<%= clienteSelecionado %>" placeholder="Digite parte do nome">
                </div>
                
                <div class="form-group">
                    <label for="ordenacao">Ordenar por:</label>
                    <select id="ordenacao" name="ordenacao">
                        <option value="data" <%= "data".equals(ordenacao) ? "selected" : "" %>>Data</option>
                        <option value="valor" <%= "valor".equals(ordenacao) ? "selected" : "" %>>Valor</option>
                        <option value="cliente" <%= "cliente".equals(ordenacao) ? "selected" : "" %>>Cliente</option>
                    </select>
                </div>
                
                <button type="submit">Aplicar Filtros</button>
                <button type="button" class="export-btn" onclick="exportToExcel()">Exportar para Excel</button>
            </form>
        </div>

        <!-- Resultados do Relatório -->
        <%
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conexao = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
            
            // Construção da consulta SQL
            String sql = "SELECT data, rg, nome_cliente, produto_id, nome_produto, " +
                         "SUM(total_valor) as valor_total, " +
                         "SUM(total_pedidos) as total_pedidos, " +
                         "SUM(total_quantidade) as quantidade_total, " +
                         "SUM(total_valor)/SUM(total_pedidos) as ticket_medio " +
                         "FROM vw_relatorio_vendas_periodo " +
                         "WHERE data BETWEEN ? AND ? ";
            
            if (!produtoSelecionado.isEmpty()) {
                sql += "AND produto_id = ? ";
            }
            
            if (!clienteSelecionado.isEmpty()) {
                sql += "AND nome_cliente LIKE ? ";
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
                ps.setString(paramIndex, "%" + clienteSelecionado + "%");
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
        
        <!-- Cartões de Resumo -->
        <div class="summary-cards">
            <div class="card">
                <h3>Período</h3>
                <div class="card-value"><%= dataInicio %> a <%= dataFim %></div>
            </div>
            <div class="card">
                <h3>Valor Total</h3>
                <div class="card-value">R$ <%= String.format("%,.2f", totalGeral) %></div>
            </div>
            <div class="card">
                <h3>Total Pedidos</h3>
                <div class="card-value"><%= String.format("%,d", totalPedidos) %></div>
            </div>
            <div class="card">
                <h3>Quantidade Vendida</h3>
                <div class="card-value"><%= String.format("%,d", totalQuantidade) %></div>
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
                    <% while (rs.next()) { %>
                        <tr>
                            <td><%= rs.getString("data") %></td>
                            <td><%= rs.getString("rg") %></td>
                            <td><%= rs.getString("nome_cliente") %></td>
                            <td><%= rs.getString("nome_produto") %></td>
                            <td class="money">R$ <%= String.format("%,.2f", rs.getDouble("valor_total")) %></td>
                            <td class="number"><%= rs.getInt("total_pedidos") %></td>
                            <td class="number"><%= rs.getInt("quantidade_total") %></td>
                            <td class="money">R$ <%= String.format("%,.2f", rs.getDouble("ticket_medio")) %></td>
                        </tr>
                    <% } %>
                    <tr class="total-row">
                        <td colspan="4"><strong>TOTAL GERAL</strong></td>
                        <td class="money"><strong>R$ <%= String.format("%,.2f", totalGeral) %></strong></td>
                        <td class="number"><strong><%= String.format("%,d", totalPedidos) %></strong></td>
                        <td class="number"><strong><%= String.format("%,d", totalQuantidade) %></strong></td>
                        <td class="money"><strong>R$ <%= String.format("%,.2f", totalGeral/totalPedidos) %></strong></td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <%
            } else {
                out.println("<p class='error'>Nenhum resultado encontrado para os filtros selecionados.</p>");
            }
        } catch (SQLException e) {
            out.println("<p class='error'>Erro ao executar consulta no banco de dados: " + e.getMessage() + "</p>");
        } finally {
            // Fecha conexões
            try { if (rs != null) rs.close(); } catch (SQLException e) { /* ignorar */ }
            try { if (ps != null) ps.close(); } catch (SQLException e) { /* ignorar */ }
            try { if (conexao != null) conexao.close(); } catch (SQLException e) { /* ignorar */ }
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
            let dateStr = today.toISOString().split('T')[0];
            a.download = "relatorio_vendas_" + dateStr + ".xls";
            
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        }
    </script>
</body>
</html>