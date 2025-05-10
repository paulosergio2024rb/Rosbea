<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Pedidos de Clientes</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4a6fa5;
            --secondary-color: #166088;
            --accent-color: #4fc3f7;
            --success-color: #4caf50;
            --error-color: #f44336;
            --light-gray: #f5f5f5;
            --medium-gray: #e0e0e0;
            --dark-gray: #757575;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Roboto', sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f9f9f9;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        h1 {
            color: var(--secondary-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
        }

        .search-container {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .search-group {
            flex: 1;
            min-width: 200px;
        }

        .search-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: var(--dark-gray);
        }

        .search-input {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid var(--medium-gray);
            border-radius: 4px;
            font-size: 14px;
        }

        .search-btn {
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 4px;
            padding: 10px 20px;
            cursor: pointer;
            height: 40px;
            align-self: flex-end;
            transition: background-color 0.3s;
        }

        .search-btn:hover {
            background-color: var(--secondary-color);
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background-color: var(--primary-color);
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            text-align: center;
            transition: background-color 0.3s;
            text-decoration: none;
            margin-right: 10px;
        }

        .btn:hover {
            background-color: var(--secondary-color);
        }

        .btn-print {
            background-color: var(--success-color);
        }

        .btn-print:hover {
            background-color: #3d8b40;
        }

        .btn-close {
            background-color: var(--error-color);
        }

        .btn-close:hover {
            background-color: #d32f2f;
        }

        .client-info {
            background-color: var(--light-gray);
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 4px solid var(--primary-color);
        }

        .client-info h2 {
            color: var(--primary-color);
            margin-bottom: 10px;
        }

        .client-info p {
            margin-bottom: 5px;
        }

        .order-header {
            background-color: var(--medium-gray);
            padding: 15px;
            border-radius: 8px 8px 0 0;
            margin-top: 20px;
        }

        .order-header h3 {
            color: var(--secondary-color);
            margin-bottom: 5px;
        }

        .table-container {
            overflow-x: auto;
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9em;
            min-width: 600px;
        }

        table thead tr {
            background-color: var(--primary-color);
            color: white;
            text-align: left;
        }

        table th, table td {
            padding: 12px 15px;
            vertical-align: middle;
        }

        table tbody tr {
            border-bottom: 1px solid var(--medium-gray);
        }

        table tbody tr:nth-of-type(even) {
            background-color: var(--light-gray);
        }

        table tbody tr:last-of-type {
            border-bottom: 2px solid var(--primary-color);
        }

        table tbody tr:hover {
            background-color: rgba(79, 195, 247, 0.1);
        }

        .order-total {
            background-color: var(--light-gray);
            padding: 15px;
            text-align: right;
            font-weight: bold;
            font-size: 1.1em;
            border-radius: 0 0 8px 8px;
            margin-bottom: 30px;
        }

        .actions {
            margin-top: 20px;
            display: flex;
            justify-content: flex-end;
        }

        .no-results {
            text-align: center;
            padding: 20px;
            color: var(--dark-gray);
            font-style: italic;
        }

        .error {
            color: var(--error-color);
            padding: 15px;
            background-color: #f2dede;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }

            .search-container {
                flex-direction: column;
            }

            .search-group {
                min-width: 100%;
            }

            .search-btn {
                width: 100%;
            }

            .actions {
                flex-direction: column;
            }

            .btn {
                width: 100%;
                margin-bottom: 10px;
                margin-right: 0;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1><i class="fas fa-shopping-bag"></i> Pedidos de Clientes</h1>

        <form method="get" action="">
            <div class="search-container">
                <div class="search-group">
                    <label for="pedido_id">Número do Pedido</label>
                    <input type="text" id="pedido_id" name="pedido_id" class="search-input"
                           value="<%= request.getParameter("pedido_id") != null ? request.getParameter("pedido_id") : "" %>">
                </div>
                <button type="submit" class="search-btn"><i class="fas fa-search"></i> Filtrar</button>
            </div>
        </form>

        <%
            // Parâmetro de filtro
            String pedidoId = request.getParameter("pedido_id");

            // Conexão com o banco de dados
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                // Configuração da conexão para MariaDB
                Class.forName("org.mariadb.jdbc.Driver");
                conn = DriverManager.getConnection(
                    "jdbc:mariadb://localhost:3306/Rosbea",
                    "paulo",
                    "6421");

                // Construção da query SQL
                String sql = "SELECT * FROM vw_clientes_pedidos WHERE 1=1";

                if (pedidoId != null && !pedidoId.isEmpty()) {
                    sql += " AND pedido_id = " + pedidoId;
                }

                sql += " ORDER BY data_pedido DESC, nome_do_cliente";

                stmt = conn.createStatement();
                rs = stmt.executeQuery(sql);

                // Variáveis para controle de agrupamento
                String currentPedidoId = "";
                String currentRg = "";
                double totalPedido = 0;
                boolean hasResults = false;

                while (rs.next()) {
                    hasResults = true;
                    String rg = rs.getString("rg");
                    String pedido_id = rs.getString("pedido_id");

                    // Se mudou o pedido, exibe os detalhes do cliente e cabeçalho do pedido
                    if (!pedido_id.equals(currentPedidoId) || !rg.equals(currentRg)) {
                        // Fecha a tabela do pedido anterior se existir
                        if (!currentPedidoId.isEmpty()) {
                            out.println("<div class='order-total'>Total do Pedido: R$ " + String.format("%.2f", totalPedido) + "</div>");
                            out.println("</div>");
                            totalPedido = 0;
                        }

                        // Exibe detalhes do cliente
                        out.println("<div class='client-info'>");
                        out.println("<h2><i class='fas fa-user'></i> " + rs.getString("nome_do_cliente") + "</h2>");
                        out.println("<p><strong><i class='fas fa-id-card'></i> RG:</strong> " + rg + "</p>");
                        out.println("<p><strong><i class='fas fa-phone'></i> Telefone:</strong> "
                            + (rs.getString("tel_cel") != null ? rs.getString("tel_cel") : "")
                            + (rs.getString("tel_fijo") != null ? " / " + rs.getString("tel_fijo") : "") + "</p>");
                        out.println("<p><strong><i class='fas fa-map-marker-alt'></i> Endereço:</strong> "
                            + rs.getString("endereco") + ", " + rs.getString("nr") + " - " + rs.getString("barrio") + "</p>");
                        out.println("<p><strong><i class='fas fa-city'></i> Cidade:</strong> "
                            + rs.getString("cidade") + " - CEP: " + rs.getString("cep") + "</p>");
                        out.println("<p><strong><i class='fas fa-envelope'></i> E-mail:</strong> "
                            + (rs.getString("email") != null ? rs.getString("email") : "") + "</p>");
                        out.println("</div>");

                        // Exibe cabeçalho do pedido
                        out.println("<div class='order-header'>");
                        out.println("<h3><i class='fas fa-receipt'></i> Pedido #" + pedido_id + " - " + rs.getString("data_pedido") + "</h3>");
                        out.println("<p><strong><i class='fas fa-comment'></i> Observações:</strong> "
                            + (rs.getString("observacoes") != null ? rs.getString("observacoes") : "Nenhuma") + "</p>");
                        out.println("</div>");

                        // Inicia tabela de itens
                        out.println("<div class='table-container'>");
                        out.println("<table>");
                        out.println("<thead>");
                        out.println("<tr>");
                        out.println("<th><i class='fas fa-box-open'></i> Produto</th>");
                        out.println("<th><i class='fas fa-tag'></i> Marca</th>");
                        out.println("<th><i class='fas fa-hashtag'></i> Quantidade</th>");
                        out.println("<th><i class='fas fa-dollar-sign'></i> Preço Unitário</th>");
                        out.println("<th><i class='fas fa-calculator'></i> Total</th>");
                        out.println("</tr>");
                        out.println("</thead>");
                        out.println("<tbody>");

                        currentPedidoId = pedido_id;
                        currentRg = rg;
                    }

                    // Exibe item do pedido
                    out.println("<tr>");
                    out.println("<td>" + rs.getString("produto_nome") + " (" + rs.getString("ml") + ")</td>");
                    out.println("<td>" + rs.getString("marca") + "</td>");
                    out.println("<td>" + rs.getString("quantidade") + "</td>");
                    out.println("<td>R$ " + String.format("%.2f", rs.getDouble("preco")) + "</td>");
                    double totalItem = rs.getDouble("quantidade") * rs.getDouble("preco");
                    out.println("<td>R$ " + String.format("%.2f", totalItem) + "</td>");
                    out.println("</tr>");

                    totalPedido += totalItem;
                }

                // Fecha a última tabela se existirem resultados
                if (!currentPedidoId.isEmpty()) {
                    out.println("</tbody>");
                    out.println("</table>");
                    out.println("</div>");
                    out.println("<div class='order-total'>Total do Pedido: R$ " + String.format("%.2f", totalPedido) + "</div>");
                    out.println("</div>");
                } else if (pedidoId != null) {
                    out.println("<div class='no-results'>");
                    out.println("<p><i class='fas fa-info-circle'></i> Nenhum pedido encontrado com o número: " + pedidoId + ".</p>");
                    out.println("</div>");
                } else if (!hasResults) {
                    out.println("<div class='no-results'>");
                    out.println("<p><i class='fas fa-info-circle'></i> Nenhum pedido cadastrado no sistema.</p>");
                    out.println("</div>");
                }

            } catch (ClassNotFoundException e) {
                out.println("<div class='error'>");
                out.println("<p><i class='fas fa-exclamation-triangle'></i> Erro: Driver JDBC do MariaDB não encontrado.</p>");
                out.println("<p>Certifique-se de que o arquivo mariadb-java-client-*.jar está no classpath.</p>");
                out.println("</div>");
            } catch (SQLException e) {
                out.println("<div class='error'>");
                out.println("<p><i class='fas fa-exclamation-triangle'></i> Erro ao acessar o banco de dados: " + e.getMessage() + "</p>");
                out.println("</div>");
            } finally {
                // Fechar recursos
                try { if (rs != null) rs.close(); } catch (SQLException e) {}
                try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
                try { if (conn != null) conn.close(); } catch (SQLException e) {}
            }
        %>

        <div class="actions">
            <button class="btn btn-print" onclick="window.print()"><i class="fas fa-print"></i> Imprimir</button>
            <button class="btn btn-close" onclick="window.close()"><i class="fas fa-times"></i> Fechar</button>
        </div>
    </div>
</body>
</html>