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
        PreparedStatement psProdutos = conProdutos.prepareStatement("SELECT codigo, nome FROM produto ORDER BY nome");
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
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <style>
        body { font-family: 'Roboto', sans-serif; }
        .container { width: 80%; margin: 0 auto; padding-top: 20px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="number"], select, button { padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; width: 100%; margin-bottom: 10px; }
        button { background-color: #4caf50; color: white; cursor: pointer; }
        button:hover { background-color: #43a047; }
        .error { color: red; margin-top: 10px; }
        .ui-autocomplete {
            max-height: 200px;
            overflow-y: auto;
            overflow-x: hidden;
        }
        .ui-autocomplete-input {
            width: 100%;
        }
        .hidden-id {
            display: none;
        }
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
                <label for="produto_search">Buscar Produto (código ou nome):</label>
                <input type="text" id="produto_search" class="ui-autocomplete-input" placeholder="Digite para buscar...">
                <input type="hidden" id="produto_id" name="produto_id" value="<%= itemData.get("produto_id") %>" required>
                <div id="selected-product" style="margin-top: 10px; padding: 8px; background-color: #f5f5f5; border-radius: 4px; display: none;">
                    <strong>Produto selecionado:</strong> <span id="selected-product-text"></span>
                </div>
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

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script>
$(document).ready(function() {
    // Array com os produtos para o autocomplete
    var produtos = [
        <% for (Map<String, Object> produto : produtos) { %>
            {
                label: "<%= produto.get("codigo") %> - <%= produto.get("nome").toString().replace("\"", "\\\"") %>",
                value: "<%= produto.get("codigo") %> - <%= produto.get("nome").toString().replace("\"", "\\\"") %>",
                id: <%= produto.get("codigo") %>
            },
        <% } %>
    ];

    // Configuração do autocomplete
    $("#produto_search").autocomplete({
        source: produtos,
        minLength: 2,
        select: function(event, ui) {
            $("#produto_id").val(ui.item.id);
            $("#selected-product-text").text(ui.item.label);
            $("#selected-product").show();
            $("#produto_search").val("");
            return false;
        },
        focus: function(event, ui) {
            return false; // Impede que o valor seja preenchido no campo ao navegar
        }
    }).autocomplete("instance")._renderItem = function(ul, item) {
        return $("<li>")
            .append("<div>" + item.label + "</div>")
            .appendTo(ul);
    };

    // Carrega o produto selecionado se estiver editando
    <% if (itemData != null && itemData.get("produto_id") != null) { %>
        var produtoId = <%= itemData.get("produto_id") %>;
        var produtoSelecionado = produtos.find(function(p) { return p.id == produtoId; });
        if (produtoSelecionado) {
            $("#selected-product-text").text(produtoSelecionado.label);
            $("#selected-product").show();
        }
    <% } %>

    // Validação do formulário
    $("form").submit(function() {
        if ($("#produto_id").val() == "") {
            alert("Por favor, selecione um produto");
            return false;
        }
        return true;
    });
});
</script>
</body>
</html>