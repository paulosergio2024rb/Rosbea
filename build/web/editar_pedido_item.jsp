<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Visualizar Item(ns) do Pedido</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #34495e;
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
            max-width: 1000px;
            margin: 0 auto;
            padding: 30px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        h1 {
            color: var(--secondary-color);
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--medium-gray);
            text-align: center;
        }

        .error-message {
            color: var(--error-color);
            background-color: #ffebee;
            border: 1px solid #ef9a9a;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .results-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            overflow: hidden;
        }

        .results-table thead tr {
            background-color: var(--primary-color);
            color: white;
            text-align: left;
        }

        .results-table th, .results-table td {
            padding: 12px 15px;
            border-bottom: 1px solid var(--medium-gray);
        }

        .results-table tbody tr:nth-child(even) {
            background-color: var(--light-gray);
        }

        .results-table tbody tr:last-child {
            border-bottom: 2px solid var(--primary-color);
        }

        .results-table tbody tr:hover {
            background-color: #e3f2fd;
        }

        .form-control {
            width: calc(100% - 12px);
            padding: 8px;
            margin: 5px 0;
            border: 1px solid var(--medium-gray);
            border-radius: 4px;
            box-sizing: border-box;
        }

        .action-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 4px;
            padding: 8px 12px;
            cursor: pointer;
            text-decoration: none;
            font-size: 0.9em;
            transition: background-color 0.3s;
        }

        .action-button:hover {
            background-color: var(--secondary-color);
        }

        .back-link {
            display: block;
            margin-top: 20px;
            text-align: center;
        }

        .back-link a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
        }

        .back-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="container">
    <h1><i class="fas fa-eye"></i> Visualizar Item(ns) do Pedido</h1>

    <%
        String itemIdStr = request.getParameter("item_id");
        String pedidoIdStr = request.getParameter("pedido_id");
        String pedidoPrincipalIdStr = request.getParameter("pedido_principal_id");
        List<Map<String, Object>> itensPedido = new ArrayList<>();
        String errorMessage = null;
        List<Map<String, Object>> produtos = new ArrayList<>();

        try {
            Class.forName("org.mariadb.jdbc.Driver");
            Connection conProdutos = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
            PreparedStatement psProdutos = conProdutos.prepareStatement("SELECT codigo, nome FROM produto ORDER BY codigo");
            ResultSet rsProdutos = psProdutos.executeQuery();

            while (rsProdutos.next()) {
                Map<String, Object> produto = new HashMap<>();
                produto.put("codigo", rsProdutos.getInt("codigo"));
                produto.put("nome", rsProdutos.getString("nome"));
                produtos.add(produto);
            }

            rsProdutos.close();
            psProdutos.close();
            conProdutos.close();

        } catch (Exception e) {
            errorMessage = "Erro ao carregar produtos: " + e.getMessage();
        }

        String sql = "SELECT id, pedido_id, produto_id, quantidade, preco FROM pedido_item WHERE 1=0";

        if (itemIdStr != null && !itemIdStr.isEmpty()) {
            sql = "SELECT id, pedido_id, produto_id, quantidade, preco FROM pedido_item WHERE id = ?";
        } else if (pedidoIdStr != null && !pedidoIdStr.isEmpty()) {
            sql = "SELECT id, pedido_id, produto_id, quantidade, preco FROM pedido_item WHERE pedido_id = ?";
        } else if (pedidoPrincipalIdStr != null && !pedidoPrincipalIdStr.isEmpty()) {
            sql = "SELECT pi.id, pi.pedido_id, pi.produto_id, pi.quantidade, pi.preco FROM pedido_item pi JOIN pedido p ON pi.pedido_id = p.id WHERE p.id = ?";
        } else {
            errorMessage = "Nenhum critério de busca fornecido.";
        }

        if (errorMessage == null && !sql.equals("SELECT id, pedido_id, produto_id, quantidade, preco FROM pedido_item WHERE 1=0")) {
            try {
                Class.forName("org.mariadb.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
                PreparedStatement ps = con.prepareStatement(sql);

                if (itemIdStr != null && !itemIdStr.isEmpty()) {
                    ps.setInt(1, Integer.parseInt(itemIdStr));
                } else if (pedidoIdStr != null && !pedidoIdStr.isEmpty()) {
                    ps.setInt(1, Integer.parseInt(pedidoIdStr));
                } else if (pedidoPrincipalIdStr != null && !pedidoPrincipalIdStr.isEmpty()) {
                    ps.setInt(1, Integer.parseInt(pedidoPrincipalIdStr));
                }

                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    Map<String, Object> itemData = new HashMap<>();
                    itemData.put("id", rs.getInt("id"));
                    itemData.put("pedido_id", rs.getInt("pedido_id"));
                    itemData.put("produto_id", rs.getInt("produto_id"));
                    itemData.put("quantidade", rs.getInt("quantidade"));
                    itemData.put("preco_unitario", rs.getDouble("preco"));
                    itensPedido.add(itemData);
                }

                rs.close();
                ps.close();
                con.close();

                if (itensPedido.isEmpty() && errorMessage == null) {
                    errorMessage = "Nenhum item do pedido encontrado com os critérios fornecidos.";
                }

            } catch (Exception e) {
                errorMessage = "Erro ao buscar item(ns) do pedido: " + e.getMessage();
            }
        }
    %>

    <% if (errorMessage != null) { %>
        <p class="error-message"><i class="fas fa-exclamation-circle"></i> <%= errorMessage %></p>
        <p class="back-link"><a href="buscar_pedido_item.jsp"><i class="fas fa-arrow-left"></i> Voltar para a busca</a></p>
    <% } else if (!itensPedido.isEmpty()) { %>
        <form>
            <table class="results-table">
                <thead>
                <tr>
                    <th>ID Item</th>
                    <th>ID Pedido</th>
                    <th>Produto</th>
                    <th>Quantidade</th>
                    <th>Preço Unitário</th>
                    <th>Ações</th>
                </tr>
                </thead>
                <tbody>
                <fieldset disabled>
                <% for (Map<String, Object> item : itensPedido) { %>
                    <tr>
                        <td><input type="text" class="form-control" value="<%= item.get("id") %>" readonly /></td>
                        <td><input type="number" class="form-control" value="<%= item.get("pedido_id") %>" readonly /></td>
                        <td>
                            <select class="form-control" disabled>
                                <% for (Map<String, Object> produto : produtos) { %>
                                    <option value="<%= produto.get("codigo") %>"
                                        <%= (item.get("produto_id") != null && item.get("produto_id").equals(produto.get("codigo"))) ? "selected" : "" %>>
                                        <%= produto.get("codigo") %> - <%= produto.get("nome") %>
                                    </option>
                                <% } %>
                            </select>
                        </td>
                        <td><input type="number" class="form-control" value="<%= item.get("quantidade") %>" readonly /></td>
                        <td><input type="number" step="0.01" class="form-control" value="<%= item.get("preco_unitario") %>" readonly /></td>
                        <td>
                            <a href="editar_item_form.jsp?item_id=<%= item.get("id") %>" class="action-button">
                                <i class="fas fa-pencil-alt"></i> Editar
                            </a>
                        </td>
                    </tr>
                <% } %>
                </fieldset>
                </tbody>
            </table>
        </form>
        <p class="back-link"><a href="buscar_pedido_item.jsp"><i class="fas fa-arrow-left"></i> Voltar para a busca</a></p>
    <% } else { %>
        <p>Nenhum item do pedido encontrado com os critérios fornecidos.</p>
        <p class="back-link"><a href="buscar_pedido_item.jsp"><i class="fas fa-arrow-left"></i> Voltar para a busca</a></p>
    <% } %>
</div>
</body>
</html>
