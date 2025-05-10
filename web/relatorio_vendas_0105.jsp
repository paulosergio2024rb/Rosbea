<%@ page import="java.sql.Connection, java.sql.DriverManager, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Calendar, java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String dbUrl = "jdbc:mariadb://localhost:3306/Rosbea";
    String dbUser = "paulo";
    String dbPassword = "6421";

    Connection conexao = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String dataInicio = request.getParameter("dataInicio");
    String dataFim = request.getParameter("dataFim");
    String loja = request.getParameter("loja");
    String ordenacao = request.getParameter("ordenacao");

    if (dataInicio == null || dataInicio.isEmpty()) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -1);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        dataInicio = sdf.format(cal.getTime());
        dataFim = sdf.format(new Date()); // Especificado como java.util.Date
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Relatório de Vendas - Rosbea</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }
        .container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h1, h2 {
            color: #333;
            text-align: center;
        }
        .filter-panel {
            background-color: #e9e9e9;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            display: flex;
            gap: 15px;
            align-items: center;
        }
        .form-group {
            display: flex;
            flex-direction: column;
        }
        label {
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        input[type="date"], select {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        button {
            background-color: #007bff;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover {
            background-color: #0056b3;
        }
        .export-btn {
            background-color: #28a745;
        }
        .export-btn:hover {
            background-color: #1e7e34;
        }
        .summary-cards {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            justify-content: center;
        }
        .card {
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 15px;
            text-align: center;
        }
        .card h3 {
            margin-top: 0;
            color: #333;
        }
        .card-value {
            font-size: 1.2em;
            font-weight: bold;
            color: #007bff;
        }
        .report-title {
            margin-top: 30px;
            margin-bottom: 15px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
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
        .money {
            text-align: right;
        }
        .number {
            text-align: center;
        }
        .total-row td {
            font-weight: bold;
            background-color: #e9ecef;
        }
        .error {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Relatório de Vendas</h1>

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
                <label for="loja">Loja:</label>
                <select id="loja" name="loja">
                    <option value="">Todas as Lojas</option>
                    <%
                        try {
                            Class.forName("org.mariadb.jdbc.Driver");
                            conexao = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
                            ps = conexao.prepareStatement("SELECT DISTINCT loja FROM vw_relatorio_vendas_periodo ORDER BY loja");
                            rs = ps.executeQuery();
                            while (rs.next()) {
                                String lojaAtual = rs.getString("loja");
                    %>
                                <option value="<%= lojaAtual %>" <%= loja != null && loja.equals(lojaAtual) ? "selected" : "" %>>
                                    <%= lojaAtual %>
                                </option>
                    <%
                            }
                        } catch (SQLException e) {
                            out.println("<span class='error'>Erro ao carregar lojas: " + e.getMessage() + "</span>");
                            e.printStackTrace();
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
                            if (conexao != null) try { conexao.close(); } catch (SQLException ignored) {}
                        }
                    %>
                </select>
            </div>

            <div class="form-group">
                <label for="ordenacao">Ordenar por:</label>
                <select id="ordenacao" name="ordenacao">
                    <option value="data" <%= "data".equals(ordenacao) ? "selected" : "" %>>Data</option>
                    <option value="loja" <%= "loja".equals(ordenacao) ? "selected" : "" %>>Loja</option>
                    <option value="valor" <%= "valor".equals(ordenacao) ? "selected" : "" %>>Valor</option>
                </select>
            </div>

            <button type="submit">Aplicar Filtros</button>
            <button type="button" class="export-btn" onclick="exportToExcel()">Exportar para Excel</button>
        </form>
    </div>

    <%
        Connection conexaoRelatorio = null; // Variável separada para a conexão do relatório
        PreparedStatement psRelatorio = null;
        ResultSet rsRelatorio = null;

        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conexaoRelatorio = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

            String sql = "SELECT data, loja, SUM(total_valor) AS valor_total, " +
                         "SUM(total_pedidos) AS total_pedidos, SUM(total_quantidade) AS quantidade_total, " +
                         "SUM(total_valor)/SUM(total_pedidos) AS ticket_medio " +
                         "FROM vw_relatorio_vendas_periodo " +
                         "WHERE data BETWEEN ? AND ? ";

            if (loja != null && !loja.isEmpty()) {
                sql += "AND loja = ? ";
            }

            sql += "GROUP BY data, loja ";

            if ("loja".equals(ordenacao)) {
                sql += "ORDER BY loja, data";
            } else if ("valor".equals(ordenacao)) {
                sql += "ORDER BY valor_total DESC";
            } else {
                sql += "ORDER BY data, loja";
            }

            psRelatorio = conexaoRelatorio.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
            psRelatorio.setString(1, dataInicio);
            psRelatorio.setString(2, dataFim);
            if (loja != null && !loja.isEmpty()) {
                psRelatorio.setString(3, loja);
            }

            rsRelatorio = psRelatorio.executeQuery();

            double totalGeral = 0;
            int totalPedidos = 0;
            int totalQuantidade = 0;

            while (rsRelatorio.next()) {
                totalGeral += rsRelatorio.getDouble("valor_total");
                totalPedidos += rsRelatorio.getInt("total_pedidos");
                totalQuantidade += rsRelatorio.getInt("quantidade_total");
            }

            if (totalGeral > 0) {
                rsRelatorio.beforeFirst();
    %>

    <div class="summary-cards">
        <div class="card"><h3>Período</h3><div class="card-value"><%= dataInicio %> a <%= dataFim %></div></div>
        <div class="card"><h3>Valor Total</h3><div class="card-value">R$ <%= String.format("%,.2f", totalGeral) %></div></div>
        <div class="card"><h3>Total Pedidos</h3><div class="card-value"><%= String.format("%,d", totalPedidos) %></div></div>
        <div class="card"><h3>Quantidade Vendida</h3><div class="card-value"><%= String.format("%,d", totalQuantidade) %></div></div>
    </div>

    <h2 class="report-title">Detalhes das Vendas</h2>

    <div style="overflow-x: auto;">
        <table border="1" id="reportTable">
            <thead>
            <tr>
                <th>Data</th>
                <th>Loja</th>
                <th class="money">Valor Total</th>
                <th class="number">Pedidos</th>
                <th class="number">Quantidade</th>
                <th class="money">Ticket Médio</th>
            </tr>
            </thead>
            <tbody>
            <% while (rsRelatorio.next()) { %>
                <tr>
                    <td><%= rsRelatorio.getString("data") %></td>
                    <td><%= rsRelatorio.getString("loja") %></td>
                    <td class="money">R$ <%= String.format("%,.2f", rsRelatorio.getDouble("valor_total")) %></td>
                    <td class="number"><%= rsRelatorio.getInt("total_pedidos") %></td>
                    <td class="number"><%= rsRelatorio.getInt("quantidade_total") %></td>
                    <td class="money">R$ <%= String.format("%,.2f", rsRelatorio.getDouble("ticket_medio")) %></td>
                </tr>
            <% } %>
            <tr class="total-row">
                <td colspan="2"><strong>TOTAL GERAL</strong></td>
                <td class="money"><strong>R$ <%= String.format("%,.2f", totalGeral) %></strong></td>
                <td class="number"><strong><%= String.format("%,d", totalPedidos) %></strong></td>
                <td class="number"><strong><%= String.format("%,d", totalQuantidade) %></strong></td>
                <td class="money"><strong>R$ <%= totalPedidos > 0 ? String.format("%,.2f", totalGeral / totalPedidos) : "0.00" %></strong></td>
            </tr>
            </tbody>
        </table>
    </div>

    <%
            } else {
                out.println("<p class='error'>Nenhum resultado encontrado para os filtros selecionados.</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>Erro ao gerar relatório: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            if (rsRelatorio != null) try { rsRelatorio.close(); } catch (SQLException ignored) {}
            if (psRelatorio != null) try { psRelatorio.close(); } catch (SQLException ignored) {}
            if (conexaoRelatorio != null) try { conexaoRelatorio.close(); } catch (SQLException ignored) {}
        }
    %>
</div>

<script>
    function exportToExcel() {
        let html = document.getElementById("reportTable").outerHTML;
        let blob = new Blob([html], {type: "application/vnd.ms-excel"});
        let a = document.createElement("a");
        a.href = URL.createObjectURL(blob);
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