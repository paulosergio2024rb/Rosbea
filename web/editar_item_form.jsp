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
<!DOCTYPE html>
<html>
<head>
    <title>Editar Item do Pedido</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <style>
        body { font-family: 'Roboto', sans-serif; margin: 20px; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background: #fff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: 500; }
        input, select, button { 
            padding: 10px; 
            width: 100%; 
            border: 1px solid #ddd; 
            border-radius: 4px; 
            box-sizing: border-box;
            font-size: 16px;
        }
        button { 
            background: #4CAF50; 
            color: white; 
            border: none; 
            cursor: pointer; 
            margin-top: 10px;
        }
        button:hover { background: #45a049; }
        .ui-autocomplete { max-height: 200px; overflow-y: auto; }
        #selected-product { margin: 10px 0; padding: 10px; background: #f9f9f9; border-radius: 4px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Editar Item do Pedido</h1>

    <% if (errorMessage != null) { %>
        <div style="color: red; padding: 10px; background: #ffeeee; border-radius: 4px;">
            <%= errorMessage %>
        </div>
        <p><a href="buscar_pedido_item.jsp">← Voltar</a></p>
    <% } else if (itemData != null) { %>
        <form id="formEditarItem" method="post" action="salvar_pedido_item.jsp">
            <input type="hidden" name="id" value="<%= itemData.get("id") %>">

            <div class="form-group">
                <label for="pedido_id">ID do Pedido:</label>
                <input type="text" id="pedido_id" name="pedido_id" value="<%= itemData.get("pedido_id") %>" readonly>
            </div>

            <div class="form-group">
                <label for="produto_search">Buscar Produto:</label>
                <input type="text" id="produto_search" placeholder="Digite código ou nome...">
                <input type="hidden" id="produto_id" name="produto_id" value="<%= itemData.get("produto_id") %>">
                <div id="selected-product" style="<%= itemData.get("produto_id") == null ? "display:none;" : "" %>">
                    <strong>Selecionado:</strong> <span id="selected-product-text"></span>
                </div>
            </div>

            <div class="form-group">
                <label for="quantidade">Quantidade:</label>
                <input type="number" id="quantidade" name="quantidade" value="<%= itemData.get("quantidade") %>" min="1">
            </div>

            <div class="form-group">
                <label for="preco_unitario">Preço Unitário:</label>
                <input type="number" id="preco_unitario" name="preco_unitario" step="0.01" value="<%= itemData.get("preco_unitario") %>">
            </div>

            <button type="submit">Salvar Alterações</button>
            <p><a href="buscar_pedido_item.jsp">← Voltar</a></p>
        </form>
    <% } else { %>
        <p>Nenhum item selecionado para edição.</p>
        <p><a href="buscar_pedido_item.jsp">← Voltar</a></p>
    <% } %>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script>
$(document).ready(function() {
    // Dados dos produtos para autocomplete
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
        }
    });

    // Faz o Enter funcionar como Tab (avança para próximo campo)
    $("input").keydown(function(e) {
        if (e.keyCode === 13) {
            e.preventDefault();
            var inputs = $("input:visible");
            var nextInput = inputs.eq(inputs.index(this) + 1);
            if (nextInput.length) {
                nextInput.focus();
            } else {
                $("button[type='submit']").focus();
            }
        }
    });

    // Carrega produto selecionado se estiver editando
    <% if (itemData != null && itemData.get("produto_id") != null) { %>
        var produtoId = <%= itemData.get("produto_id") %>;
        var produtoSelecionado = produtos.find(function(p) { return p.id == produtoId; });
        if (produtoSelecionado) {
            $("#selected-product-text").text(produtoSelecionado.label);
        }
    <% } %>
});
</script>
</body>
</html>