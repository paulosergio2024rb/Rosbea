<%@page import="java.sql.*" %>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Novo Pedido</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        .total { font-weight: bold; font-size: 1.2em; }
        .btn { padding: 5px 10px; margin-top: 10px; }
        .error { color: red; margin: 10px 0; }
    </style>
    <script>
        function atualizarPreco(e) {
            const row = e.target.closest('tr');
            const selected = e.target.selectedOptions[0];
            const preco = selected.getAttribute("data-preco");
            row.querySelector(".preco").value = preco;
            calcularSubtotal(row);
        }

        function calcularSubtotal(row) {
            const qtd = parseFloat(row.querySelector(".quantidade").value || 0);
            const preco = parseFloat(row.querySelector(".preco").value || 0);
            const subtotal = qtd * preco;
            row.querySelector(".subtotal").value = subtotal.toFixed(2);
            calcularTotal();
        }

        function calcularTotal() {
            const subtotais = document.querySelectorAll(".subtotal");
            let total = 0;
            subtotais.forEach(input => total += parseFloat(input.value || 0));
            document.getElementById("totalPedido").innerText = total.toFixed(2);
        }

        function adicionarItem() {
            const tabela = document.getElementById("itens");
            const novaLinha = tabela.rows[1].cloneNode(true);
            novaLinha.querySelector(".quantidade").value = "";
            novaLinha.querySelector(".preco").value = "";
            novaLinha.querySelector(".subtotal").value = "";
            tabela.appendChild(novaLinha);
        }
        
        function validarFormulario() {
            const itens = document.querySelectorAll('#itens tbody tr');
            let valido = true;
            
            itens.forEach((item, index) => {
                const produto = item.querySelector('select');
                const quantidade = item.querySelector('.quantidade');
                
                if (produto.value === "") {
                    alert(`Selecione um produto para o item ${index + 1}`);
                    valido = false;
                }
                
                if (quantidade.value === "" || parseFloat(quantidade.value) <= 0) {
                    alert(`Informe uma quantidade válida para o item ${index + 1}`);
                    valido = false;
                }
            });
            
            return valido;
        }
    </script>
</head>
<body>
    <h2>Novo Pedido</h2>
    
    <% if (request.getParameter("erro") != null) { %>
        <div class="error">Erro: <%= request.getParameter("erro") %></div>
    <% } %>

    <form method="post" action="salvar_pedido.jsp" onsubmit="return validarFormulario()">
        <label>Cliente:</label>
        <select name="cliente_id" required>
            <%
                Connection con = null;
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
                    PreparedStatement stmt = con.prepareStatement("SELECT rg, nome_do_cliente FROM cadastro_de_clientes ORDER BY nome_do_cliente");
                    ResultSet rs = stmt.executeQuery();
                    while (rs.next()) {
            %>
            <option value="<%= rs.getString("rg") %>"><%= rs.getString("nome_do_cliente") %></option>
            <%
                    }
                } catch (Exception e) {
                    out.print("<div class='error'>Erro ao carregar clientes: " + e.getMessage() + "</div>");
                } finally {
                    if (con != null) con.close();
                }
            %>
        </select>

        <table id="itens">
            <tr>
                <th>Produto</th>
                <th>Quantidade</th>
                <th>Preço</th>
                <th>Subtotal</th>
            </tr>
            <tr>
                <td>
                    <select name="produto_id[]" onchange="atualizarPreco(event)" required>
                        <option value="">-- Selecione --</option>
                        <%
                            try {
                                Class.forName("org.mariadb.jdbc.Driver");
                                con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
                                PreparedStatement ps = con.prepareStatement("SELECT codigo, nome, preco FROM produto ORDER BY nome");
                                ResultSet produtos = ps.executeQuery();
                                while (produtos.next()) {
                        %>
                        <option value="<%= produtos.getInt("codigo") %>" data-preco="<%= produtos.getDouble("preco") %>">
                            <%= produtos.getString("nome") %>
                        </option>
                        <%
                                }
                            } catch (Exception ex) {
                                out.print("<div class='error'>Erro ao carregar produtos: " + ex.getMessage() + "</div>");
                            } finally {
                                if (con != null) con.close();
                            }
                        %>
                    </select>
                </td>
                <td><input type="number" name="quantidade[]" class="quantidade" oninput="calcularSubtotal(this.closest('tr'))" min="1" required></td>
                <td><input type="text" class="preco" name="preco[]" readonly></td>
                <td><input type="text" class="subtotal" readonly></td>
            </tr>
        </table>

        <button type="button" class="btn" onclick="adicionarItem()">+ Adicionar Item</button><br><br>

        <div>Total do Pedido: R$ <span id="totalPedido">0.00</span></div><br>

        <input type="submit" value="Salvar Pedido" class="btn">
    </form>
</body>
</html>