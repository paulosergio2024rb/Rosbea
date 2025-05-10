<%@page import="java.sql.*"%>
<%@page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Buscar Pedido para Exclusão</title>
    <style>
        body {
            font-family: sans-serif;
            background-color: #f4f4f4;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding-top: 20px;
        }
        h1, h2 {
            color: #333;
            margin-bottom: 20px;
        }
        form {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            text-align: center;
        }
        label {
            display: block;
            margin-bottom: 10px;
            font-weight: bold;
        }
        input[type="number"] {
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            margin-bottom: 15px;
            width: 200px;
        }
        input[type="submit"] {
            background-color: #007bff;
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        input[type="submit"]:hover {
            background-color: #0056b3;
        }
        .error {
            color: #d9534f;
            font-weight: bold;
            margin-top: 15px;
        }
        table {
            width: 80%;
            border-collapse: collapse;
            margin-top: 20px;
            background-color: #fff;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .delete-form {
            text-align: center;
            margin-top: 20px;
        }
        .delete-button {
            background-color: #d9534f;
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        .delete-button:hover {
            background-color: #c9302c;
        }
    </style>
</head>
<body>
    <h1>Buscar Pedido para Exclusão</h1>

    <form method="GET" action="busca_exclusao_pedido.jsp">
        <label for="pedido_id">Buscar por ID do Pedido:</label>
        <input type="number" id="pedido_id" name="pedido_id">
        <input type="submit" value="Buscar">
    </form>

    <%
    String pedidoIdBusca = request.getParameter("pedido_id");
    if (pedidoIdBusca != null && !pedidoIdBusca.isEmpty()) {
        Connection con = null;
        PreparedStatement psRelatorio = null;
        ResultSet rsRelatorio = null;
        boolean encontrouPedido = false;

        try {
            Class.forName("org.mariadb.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

            String sqlRelatorio = "SELECT * FROM vw_exclusao_pedido WHERE pedido_id = ?";
            psRelatorio = con.prepareStatement(sqlRelatorio);

            int pedidoIdIntBusca;
            try {
                pedidoIdIntBusca = Integer.parseInt(pedidoIdBusca);
                psRelatorio.setInt(1, pedidoIdIntBusca);
            } catch (NumberFormatException e) {
                out.println("<p class='error'>Erro: ID do pedido para busca inválido. Por favor, insira um número inteiro.</p>");
                e.printStackTrace();
                return; // Interrompe o processamento se o ID for inválido
            }

            rsRelatorio = psRelatorio.executeQuery();

            if (rsRelatorio.next()) {
                encontrouPedido = true;
                out.println("<h2>Detalhes do Pedido #" + pedidoIdBusca + " para Exclusão</h2>");
                out.println("<table>");
                out.println("<thead><tr><th>Pedido ID</th><th>Cliente ID</th><th>Data Pedido</th><th>Mês Pedido</th><th>Observações</th>");
                out.println("<th>Item ID</th><th>Produto ID</th><th>Quantidade</th><th>Preço Unitário</th><th>Total Item</th>");
                out.println("<th>Vencimento ID</th><th>Nr Pedido (Venc)</th><th>Data Vencimento</th><th>Valor Pedido</th><th>Prazo</th><th>Pago</th><th>Resultado</th><th>Vencimento</th></tr></thead>");
                out.println("<tbody>");
                do {
                    out.println("<tr>");
                    out.println("<td>" + rsRelatorio.getInt("pedido_id") + "</td>");
                    out.println("<td>" + rsRelatorio.getString("cliente_id") + "</td>");
                    out.println("<td>" + rsRelatorio.getDate("data_pedido") + "</td>");
                    out.println("<td>" + rsRelatorio.getString("pedido_mes_atual") + "</td>");
                    out.println("<td>" + rsRelatorio.getString("pedido_observacoes") + "</td>");
                    out.println("<td>" + (rsRelatorio.getInt("item_id") == 0 ? "" : rsRelatorio.getInt("item_id")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getInt("produto_id") == 0 ? "" : rsRelatorio.getInt("produto_id")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getInt("quantidade") == 0 ? "" : rsRelatorio.getInt("quantidade")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getDouble("preco_unitario") == 0.0 ? "" : rsRelatorio.getDouble("preco_unitario")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getDouble("total_item") == 0.0 ? "" : rsRelatorio.getDouble("total_item")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getInt("vencimento_id") == 0 ? "" : rsRelatorio.getInt("vencimento_id")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getInt("nr_pedido") == 0 ? "" : rsRelatorio.getInt("nr_pedido")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getDate("data_pedidovcto") == null ? "" : rsRelatorio.getDate("data_pedidovcto")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getDouble("valor_ped") == 0.0 ? "" : rsRelatorio.getDouble("valor_ped")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getInt("prazo") == 0 ? "" : rsRelatorio.getInt("prazo")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getString("pgto") == null ? "" : rsRelatorio.getString("pgto")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getString("resultado") == null ? "" : rsRelatorio.getString("resultado")) + "</td>");
                    out.println("<td>" + (rsRelatorio.getDate("data_vencimento") == null ? "" : rsRelatorio.getDate("data_vencimento")) + "</td>");
                    out.println("</tr>");
                } while (rsRelatorio.next());
                out.println("</tbody></table>");

                // Formulário para exclusão com botão estilizado
                out.println("<div class=\"delete-form\">");
                out.println("<form method=\"POST\" action=\"exclusao_pedido.jsp\">");
                out.println("<input type=\"hidden\" name=\"pedido_id\" value=\"" + pedidoIdBusca + "\">");
                out.println("<button type=\"submit\" class=\"delete-button\" onclick=\"return confirm('Tem certeza que deseja excluir todos os dados relacionados ao pedido " + pedidoIdBusca + "?')\">Excluir Pedido e Dados Relacionados</button>");
                out.println("</form>");
                out.println("</div>");

            } else {
                out.println("<p class='error'>Nenhum pedido encontrado com o ID: " + pedidoIdBusca + "</p>");
            }

        } catch (Exception e) {
            out.println("<p class='error'>Erro ao acessar o banco de dados: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            try { if (rsRelatorio != null) rsRelatorio.close(); } catch (SQLException e) {}
            try { if (psRelatorio != null) psRelatorio.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
    %>

</body>
</html>