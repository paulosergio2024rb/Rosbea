<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String itemIdToEditStr = request.getParameter("item_id");
    int itemIdToEdit = 0;
    Map<String, Object> itemData = null;
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

    if (itemIdToEditStr != null && !itemIdToEditStr.isEmpty()) {
        try {
            itemIdToEdit = Integer.parseInt(itemIdToEditStr);

            Class.forName("org.mariadb.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
            PreparedStatement ps = con.prepareStatement("SELECT id, pedido_id, produto_id, quantidade, preco FROM pedido_item WHERE id = ?");
            ps.setInt(1, itemIdToEdit);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                itemData = new HashMap<>();
                itemData.put("id", rs.getInt("id"));
                itemData.put("pedido_id", rs.getInt("pedido_id"));
                itemData.put("produto_id", rs.getInt("produto_id"));
                itemData.put("quantidade", rs.getInt("quantidade"));
                itemData.put("preco_unitario", rs.getDouble("preco"));
            } else {
                if (errorMessage == null) {
                    errorMessage = "Item do pedido não encontrado com o ID: " + itemIdToEdit;
                }
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            if (errorMessage == null) {
                errorMessage = "Erro ao buscar item do pedido: " + e.getMessage();
            }
        }
    }
%>
<html>
<head>
    <title>Editar Item do Pedido</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Roboto', sans-serif; }
        .container { width: 80%; margin: 0 auto; padding-top: 20px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="number"], select, button { padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; width: 100%; margin-bottom: 10px; }
        button { background-color: #4caf50; color: white; cursor: pointer; }
        button:hover { background-color: #43a047; }
        .error { color: red; margin-top: 10px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Editar Item do Pedido</h1>

    <% if (errorMessage != null) { %>
        <p class="error"><%= errorMessage %></p>
        <p><a href="buscar_pedido_item.jsp">Voltar para a busca</a></p>
    <% } else if (itemData != null) { %>
        <form action="salvar_pedido_item.jsp" method="post">
            <input type="hidden" name="id" value="<%= itemData.get("id") %>">

            <div class="form-group">
                <label for="pedido_id">ID do Pedido:</label>
                <input type="number" id="pedido_id" name="pedido_id" value="<%= itemData.get("pedido_id") %>" readonly>
            </div>

            <div class="form-group">
                <label for="produto_id">Produto:</label>
                <select id="produto_id" name="produto_id" class="form-control" required>
                    <option value="">-- Selecione um Produto --</option>
                    <% for (Map<String, Object> produto : produtos) { %>
                        <option value="<%= produto.get("codigo") %>"
                                <%= (itemData.get("produto_id") != null && itemData.get("produto_id").equals(produto.get("codigo"))) ? "selected" : "" %>>
                            <%= produto.get("codigo") %> - <%= produto.get("nome") %>
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="form-group">
                <label for="quantidade">Quantidade:</label>
                <input type="number" id="quantidade" name="quantidade" value="<%= itemData.get("quantidade") %>" required>
            </div>

            <div class="form-group">
                <label for="preco_unitario">Preço Unitário:</label>
                <input type="number" step="0.01" id="preco_unitario" name="preco_unitario" value="<%= itemData.get("preco_unitario") %>" required>
            </div>

            <button type="submit">Salvar Alterações</button>
            <p><a href="buscar_pedido_item.jsp">Voltar para a busca</a></p>
        </form>
    <% } else if (errorMessage == null && itemIdToEditStr != null) { %>
        <p>Item do pedido com ID <%= itemIdToEditStr %> não encontrado.</p>
        <p><a href="buscar_pedido_item.jsp">Voltar para a busca</a></p>
    <% } else { %>
        <p>Nenhum ID de item do pedido fornecido para edição.</p>
        <p><a href="buscar_pedido_item.jsp">Voltar para a busca</a></p>
    <% } %>
</div>
</body>
</html>