<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Map" %>

<%
    // Verificação de permissão e sessão
    Integer permissao = (Integer) session.getAttribute("permissao");
    String usuario = (String) session.getAttribute("usuario");

    if (usuario == null || permissao == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Obter o parâmetro mes_atual da URL
    String mesAtual = request.getParameter("mes_atual");

    // Se não houver parâmetro, mostrar o seletor de mês
    if (mesAtual == null || mesAtual.isEmpty()) {
%>
<!DOCTYPE html>
<html>
    <head>
        <a href="relatorios.html"></i> Voltar</a> 
        <title>Relatório de Revendedores - Sistema Rosbea</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #2c3e50;
                --secondary-color: #3498db;
                --accent-color: #e74c3c;
                --light-color: #ecf0f1;
                --dark-color: #2c3e50;
                --text-light: #ffffff;
                --text-dark: #333333;
                --shadow-sm: 0 2px 5px rgba(0, 0, 0, 0.1);
                --shadow-md: 0 4px 10px rgba(0, 0, 0, 0.1);
                --transition: all 0.3s ease;
                --border-radius: 8px;
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f5f7fa;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }

            header {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: var(--text-light);
                padding: 1.5rem 2rem;
                text-align: center;
                box-shadow: var(--shadow-md);
                margin-bottom: 2rem;
            }

            header h1 {
                font-size: 1.8rem;
                font-weight: 500;
                margin: 0.5rem 0;
            }

            .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 2rem;
                flex: 1;
            }

            .card {
                background-color: white;
                border-radius: var(--border-radius);
                padding: 2rem;
                box-shadow: var(--shadow-sm);
            }

            .card-title {
                color: var(--primary-color);
                font-size: 1.5rem;
                margin-bottom: 1.5rem;
                text-align: center;
            }

            .form-group {
                margin-bottom: 1.5rem;
            }

            label {
                display: block;
                margin-bottom: 0.5rem;
                font-weight: 500;
                color: var(--dark-color);
            }

            select {
                width: 100%;
                padding: 0.8rem 1rem;
                border: 1px solid #ddd;
                border-radius: var(--border-radius);
                font-size: 1rem;
                transition: var(--transition);
            }

            select:focus {
                outline: none;
                border-color: var(--secondary-color);
                box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
            }

            .btn {
                background-color: var(--secondary-color);
                color: white;
                padding: 0.8rem 1.5rem;
                border: none;
                border-radius: var(--border-radius);
                cursor: pointer;
                font-size: 1rem;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 0.5rem;
                transition: var(--transition);
                box-shadow: var(--shadow-sm);
                width: 100%;
                margin-top: 1rem;
            }

            .btn:hover {
                background-color: var(--primary-color);
                transform: translateY(-2px);
                box-shadow: var(--shadow-md);
            }

            footer {
                background-color: var(--dark-color);
                color: var(--text-light);
                text-align: center;
                padding: 1.2rem;
                font-size: 0.9rem;
            }

            @media (max-width: 768px) {
                .container {
                    padding: 1rem;
                }

                .card {
                    padding: 1.5rem;
                }
            }
        </style>
    </head>
    <body>
        <header>
            <h1><i class="fas fa-users"></i> Relatório de Revendedores</h1>
        </header>

        <div class="container">
            <div class="card">
                <h2 class="card-title">Selecione o Mês</h2>
                <form method="GET" action="relatorio_revendedores_mes.jsp">
                    <div class="form-group">
                        <label for="mes_atual"><i class="fas fa-calendar-alt"></i> Mês de Referência:</label>
                        <select id="mes_atual" name="mes_atual" required>
                            <option value="">-- Selecione --</option>
                            <option value="2025-01">Janeiro 2025</option>
                            <option value="2025-02">Fevereiro 2025</option>
                            <option value="2025-03">Março 2025</option>
                            <option value="2025-04">Abril 2025</option>
                            <option value="2025-05">Maio 2025</option>
                            <option value="2025-06">Junho 2025</option>
                            <option value="2025-07">Julho 2025</option>
                            <option value="2025-08">Agosto 2025</option>
                            <option value="2025-09">Setembro 2025</option>
                            <option value="2025-10">Outubro 2025</option>
                            <option value="2025-11">Novembro 2025</option>
                            <option value="2025-12">Dezembro 2025</option>
                        </select>
                    </div>
                    <button type="submit" class="btn">
                        <i class="fas fa-file-alt"></i> Gerar Relatório
                    </button>
                </form>
            </div>
        </div>

        <footer>
            <p><i class="fas fa-quote-left"></i> Se você pode sonhar, você pode realizar. <i class="fas fa-quote-right"></i></p>
        </footer>
    </body>
</html>
<%
        return;
    }

    // Se chegou aqui, o parâmetro mes_atual foi fornecido
    DecimalFormat df = new DecimalFormat("#,##0.00");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        // Query para obter os dados agrupados por RG (somente revendedores)
        String sql = "SELECT rg, nome_do_cliente, cidade, "
                + "SUM(quantidade) as total_quantidade, "
                + "SUM(total_item) as total_valor, "
                + "COUNT(DISTINCT pedido_id) as total_pedidos "
                + "FROM view_relatorio_pedidos_revenda "
                + "WHERE CAST(SUBSTRING(?, 6, 2) AS UNSIGNED) = mes_atual AND tipo_cliente = 'revendedor' "
                + "GROUP BY rg, nome_do_cliente, cidade "
                + "ORDER BY nome_do_cliente";

        ps = con.prepareStatement(sql);
        ps.setString(1, mesAtual);
        rs = ps.executeQuery();
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Relatório de Revendedores - Sistema Rosbea</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #2c3e50;
                --secondary-color: #3498db;
                --accent-color: #e74c3c;
                --light-color: #ecf0f1;
                --dark-color: #2c3e50;
                --text-light: #ffffff;
                --text-dark: #333333;
                --shadow-sm: 0 2px 5px rgba(0, 0, 0, 0.1);
                --shadow-md: 0 4px 10px rgba(0, 0, 0, 0.1);
                --transition: all 0.3s ease;
                --border-radius: 8px;
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f5f7fa;
                color: var(--text-dark);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }

            header {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: var(--text-light);
                padding: 1.5rem 2rem;
                text-align: center;
                box-shadow: var(--shadow-md);
                margin-bottom: 2rem;
                position: relative;
            }

            header h1 {
                font-size: 1.8rem;
                font-weight: 500;
                margin: 0.5rem 0;
            }

            .actions {
                position: absolute;
                top: 1.5rem;
                right: 2rem;
                display: flex;
                gap: 0.5rem;
            }

            .btn {
                background-color: var(--accent-color);
                color: white;
                padding: 0.7rem 1.2rem;
                border: none;
                border-radius: 30px;
                text-decoration: none;
                cursor: pointer;
                font-size: 0.9rem;
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                transition: var(--transition);
                box-shadow: var(--shadow-sm);
            }

            .btn:hover {
                transform: translateY(-2px);
                box-shadow: var(--shadow-md);
            }

            .btn-secondary {
                background-color: var(--secondary-color);
            }

            .container {
                flex: 1;
                padding: 2rem;
                max-width: 1200px;
                margin: 0 auto;
                width: 100%;
            }

            .report-header {
                background-color: white;
                border-radius: var(--border-radius);
                padding: 1.5rem;
                margin-bottom: 2rem;
                box-shadow: var(--shadow-sm);
            }

            .report-title {
                color: var(--primary-color);
                font-size: 1.5rem;
                margin-bottom: 0.5rem;
            }

            .report-subtitle {
                color: var(--secondary-color);
                font-size: 1.2rem;
                margin-bottom: 1rem;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 2rem;
                box-shadow: var(--shadow-sm);
                background-color: white;
                border-radius: var(--border-radius);
                overflow: hidden;
            }

            th, td {
                padding: 12px 15px;
                text-align: left;
                border-bottom: 1px solid #e0e0e0;
            }

            th {
                background-color: var(--primary-color);
                color: white;
                font-weight: 500;
            }

            tr:nth-child(even) {
                background-color: #f9f9f9;
            }

            .text-right {
                text-align: right;
            }

            .text-center {
                text-align: center;
            }

            .total-summary {
                background-color: white;
                padding: 1.5rem;
                border-radius: var(--border-radius);
                margin-top: 1rem;
                box-shadow: var(--shadow-sm);
                font-weight: 500;
            }

            .total-summary div {
                margin-bottom: 0.5rem;
            }

            .btn-action {
                background-color: var(--secondary-color);
                padding: 0.5rem 1rem;
                font-size: 0.85rem;
            }

            .no-results {
                background-color: white;
                padding: 2rem;
                text-align: center;
                border-radius: var(--border-radius);
                box-shadow: var(--shadow-sm);
            }

            footer {
                background-color: var(--dark-color);
                color: var(--text-light);
                text-align: center;
                padding: 1.2rem;
                font-size: 0.9rem;
            }

            footer p {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 0.5rem;
            }

            @media print {
                .no-print {
                    display: none;
                }

                body {
                    background-color: white;
                    font-size: 12pt;
                }

                .container {
                    padding: 0;
                }

                header {
                    display: none;
                }

                .report-header {
                    box-shadow: none;
                    padding: 0 0 1rem 0;
                }
            }

            @media (max-width: 768px) {
                header {
                    padding: 1rem;
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                }

                .actions {
                    position: static;
                    width: 100%;
                    justify-content: center;
                    margin-top: 1rem;
                }

                th, td {
                    padding: 8px 10px;
                    font-size: 0.9rem;
                }
            }
        </style>
    </head>
    <body>
        <header>
            <h1><i class="fas fa-users"></i> Relatório de Revendedores</h1>
            <div class="actions no-print">
                <a href="relatorio_revendedores_mes.jsp" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> Voltar</a>
                <button onclick="window.print()" class="btn"><i class="fas fa-print"></i> Imprimir</button>
            </div>
        </header>

        <div class="container">
            <div class="report-header">
                <h2 class="report-title">Relatório Mensal de Revendedores</h2>
                <h3 class="report-subtitle"><i class="fas fa-calendar-alt"></i> Mês de referência: <%= mesAtual%></h3>
            </div>

            <%
                int totalQuantidadeGeral = 0;
                double totalPedidoGeral = 0.0;
                int totalRevendedores = 0;
                boolean encontrouResultados = false;
            %>

            <table>
                <thead>
                    <tr>
                        <th>RG</th>
                        <th>Revendedor</th>
                        <th>Cidade</th>
                        <th class="text-center">Total Pedidos</th>
                        <th class="text-right">Total Quantidade</th>
                        <th class="text-right">Total Valor</th>
                        <th class="text-right">Ticket Médio</th>
                        <th class="text-center no-print">Ações</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        while (rs.next()) {
                            encontrouResultados = true;
                            totalRevendedores++;

                            String rg = rs.getString("rg");
                            String nomeCliente = rs.getString("nome_do_cliente");
                            int totalQuantidade = rs.getInt("total_quantidade");
                            double totalValor = rs.getDouble("total_valor");
                            int totalPedidos = rs.getInt("total_pedidos");
                            double ticketMedio = totalPedidos > 0 ? totalValor / totalPedidos : 0;

                            totalQuantidadeGeral += totalQuantidade;
                            totalPedidoGeral += totalValor;
                    %>
                    <tr>
                        <td><%= rg%></td>
                        <td><%= nomeCliente%></td>
                        <td><%= rs.getString("cidade")%></td>
                        <td class="text-center"><%= totalPedidos%></td>
                        <td class="text-right"><%= totalQuantidade%></td>
                        <td class="text-right">R$ <%= df.format(totalValor)%></td>
                        <td class="text-right">R$ <%= df.format(ticketMedio)%></td>
                        <td class="text-center no-print">
                            <button onclick="window.open('detalhes_revendedor_mes.jsp?rg=<%= rg%>&mes_atual=<%= mesAtual%>', '_blank', 'width=1000,height=600')" 
                                    class="btn btn-action">
                                <i class="fas fa-search"></i> Detalhes
                            </button>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

            <%
                if (!encontrouResultados) {
            %>
            <div class="no-results">
                <p><i class="fas fa-info-circle"></i> Nenhum revendedor encontrado para o mês selecionado.</p>
            </div>
            <%
            } else {
            %>
            <div class="total-summary">
                <div><i class="fas fa-users"></i> Total de Revendedores: <%= totalRevendedores%></div>
                <div><i class="fas fa-cubes"></i> Total de Quantidade: <%= totalQuantidadeGeral%></div>
                <div><i class="fas fa-money-bill-wave"></i> Total Geral: R$ <%= df.format(totalPedidoGeral)%></div>
            </div>
            <%
                }
            %>
        </div>

        <footer>
            <p><i class="fas fa-quote-left"></i> Se você pode sonhar, você pode realizar. <i class="fas fa-quote-right"></i></p>
        </footer>
        <a href="index.jsp" class="btn-voltar">
            <i class="fas fa-arrow-left"></i> Voltar ao Início
        </a>
    </body>
</html>
<%
} catch (Exception e) {
%>
<div class="container">
    <div class="error-message" style="background-color: #ffebee; padding: 1.5rem; border-radius: var(--border-radius);">
        <h2 style="color: var(--accent-color);"><i class="fas fa-exclamation-triangle"></i> Erro ao acessar o banco de dados:</h2>
        <p><%= e.getMessage()%></p>
    </div>
</div>
<%
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (Exception e) {
        }
        try {
            if (ps != null) {
                ps.close();
            }
        } catch (Exception e) {
        }
        try {
            if (con != null) {
                con.close();
            }
        } catch (Exception e) {
        }
    }
%>