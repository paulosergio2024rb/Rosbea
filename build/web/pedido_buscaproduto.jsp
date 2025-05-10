<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<%
// Formatador de data
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

// Variáveis e configurações iniciais
String pedidoId = request.getParameter("pedido_id");
boolean isEdit = pedidoId != null && !pedidoId.isEmpty();

// Dados do pedido para edição
Map<String, Object> pedidoData = new HashMap<>();
List<Map<String, Object>> itensPedido = new ArrayList<>();
List<Map<String, Object>> todosProdutos = new ArrayList<>();

// Carregar todos os produtos disponíveis
Connection conProdutos = null;
try {
    Class.forName("org.mariadb.jdbc.Driver");
    conProdutos = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
    PreparedStatement psProdutos = conProdutos.prepareStatement(
        "SELECT codigo, nome, preco FROM produto ORDER BY nome");
    ResultSet rsProdutos = psProdutos.executeQuery();
    
    while (rsProdutos.next()) {
        Map<String, Object> produto = new HashMap<>();
        produto.put("codigo", rsProdutos.getInt("codigo"));
        produto.put("nome", rsProdutos.getString("nome"));
        produto.put("preco", rsProdutos.getDouble("preco"));
        todosProdutos.add(produto);
    }
} catch (Exception e) {
    out.print("<div class='message error'>Erro ao carregar produtos: " + e.getMessage() + "</div>");
} finally {
    if (conProdutos != null) try { conProdutos.close(); } catch (SQLException e) {}
}

// Carregar dados do pedido se estiver editando
if (isEdit) {
    Connection con = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
        
        // Carregar dados básicos do pedido
        PreparedStatement psPedido = con.prepareStatement(
            "SELECT p.*, c.rg, c.nome_do_cliente FROM pedido p " +
            "JOIN cadastro_de_clientes c ON p.cliente_id = c.rg " +
            "WHERE p.id = ?");
        psPedido.setInt(1, Integer.parseInt(pedidoId));
        ResultSet rsPedido = psPedido.executeQuery();
        
        if (rsPedido.next()) {
            pedidoData.put("cliente_rg", rsPedido.getString("rg"));
            pedidoData.put("cliente_nome", rsPedido.getString("nome_do_cliente"));
            pedidoData.put("data_pedido", rsPedido.getDate("data_pedido"));
            pedidoData.put("data_atende", rsPedido.getDate("data_atende"));
            pedidoData.put("mes_atual", rsPedido.getString("mes_atual"));
            pedidoData.put("observacoes", rsPedido.getString("observacoes"));
            pedidoData.put("mostruario", rsPedido.getString("mostruario"));
        }
        
        // Carregar itens do pedido (incluindo desconto da tabela pedido_itens)
        PreparedStatement psItens = con.prepareStatement(
            "SELECT pi.*, p.nome, p.preco FROM pedido_itens pi " +
            "JOIN produto p ON pi.produto_id = p.codigo " +
            "WHERE pi.pedido_id = ?");
        psItens.setInt(1, Integer.parseInt(pedidoId));
        ResultSet rsItens = psItens.executeQuery();
        
        while (rsItens.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("produto_id", rsItens.getInt("produto_id"));
            item.put("quantidade", rsItens.getInt("quantidade"));
            item.put("preco_unitario", rsItens.getDouble("preco_unitario"));
            item.put("desconto", rsItens.getDouble("desconto"));
            item.put("preco_de_venda", rsItens.getDouble("preco_unitario") - rsItens.getDouble("desconto"));
            item.put("nome_produto", rsItens.getString("nome"));
            item.put("preco", rsItens.getDouble("preco"));
            itensPedido.add(item);
        }
        
    } catch (Exception e) {
        out.print("<div class='message error'>Erro ao carregar pedido: " + e.getMessage() + "</div>");
    } finally {
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
}
%>
<html>
<head>
    <title><%= isEdit ? "Editar Pedido" : "Novo Pedido" %></title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
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
        }

        header {
            background-color: var(--primary-color);
            color: white;
            padding: 15px 0;
            margin-bottom: 20px;
            border-radius: 5px;
        }

        header h1 {
            text-align: center;
            font-weight: 500;
        }

        .card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 25px;
            margin-bottom: 30px;
        }

        .card h2 {
            color: var(--secondary-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: var(--secondary-color);
        }

        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid var(--medium-gray);
            border-radius: 4px;
            font-size: 16px;
            transition: border 0.3s;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--accent-color);
            box-shadow: 0 0 0 2px rgba(79, 195, 247, 0.2);
        }

        select.form-control {
            height: auto;
            padding: 10px;
        }

        .btn {
            display: inline-block;
            background-color: var(--primary-color);
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            text-align: center;
            transition: all 0.3s;
            text-decoration: none;
        }

        .btn:hover {
            background-color: var(--secondary-color);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn-danger {
            background-color: var(--error-color);
        }

        .btn-success {
            background-color: var(--success-color);
        }

        .table-responsive {
            overflow-x: auto;
            margin: 20px 0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }

        table th, table td {
            padding: 12px 15px;
            border: 1px solid var(--medium-gray);
            text-align: left;
        }

        table th {
            background-color: var(--primary-color);
            color: white;
        }

        table tr:nth-child(even) {
            background-color: var(--light-gray);
        }

        .total {
            font-weight: bold;
            font-size: 1.2em;
            margin: 15px 0;
            padding: 10px;
            background-color: var(--light-gray);
            border-radius: 4px;
            text-align: right;
        }

        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 4px;
            text-align: center;
        }

        .success {
            background-color: #dff0d8;
            color: #3c763d;
        }

        .error {
            background-color: #f2dede;
            color: #a94442;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .action-buttons .btn {
            flex: 1;
        }

        /* Estilos para o autocomplete */
        .ui-autocomplete {
            max-height: 200px;
            overflow-y: auto;
            overflow-x: hidden;
        }
        
        .hidden-select {
            display: none;
        }
        
        #cliente_info {
            margin-top: 5px;
            font-size: 0.9em;
            color: var(--secondary-color);
        }
        
        .ui-menu-item {
            padding: 8px 15px;
            cursor: pointer;
        }
        
        .ui-menu-item:hover {
            background-color: var(--light-gray);
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Sistema de Pedidos</h1>
        </header>

        <div class="card">
            <h2><%= isEdit ? "Editar Pedido #" + pedidoId : "Novo Pedido" %></h2>

            <% if (request.getParameter("saved") != null) { %>
                <div class="message success">Pedido salvo com sucesso!</div>
            <% } %>

            <form action="salvar_pedido.jsp" method="post" onsubmit="return validarFormulario()">
                <% if (isEdit) { %>
                    <input type="hidden" name="pedido_id" value="<%= pedidoId %>">
                    <input type="hidden" name="action" value="editar">
                <% } %>

                <div class="form-group">
                    <label>Cliente:</label>
                    <input type="text" id="cliente_search" class="form-control" placeholder="Digite o nome do cliente..." 
                           value="<%= isEdit ? pedidoData.get("cliente_nome") : "" %>" autocomplete="off">
                    <select name="cliente_rg" id="cliente_rg" class="hidden-select" required>
                        <option value="">-- Selecione um cliente --</option>
                        <%
                            Connection conCliente = null;
                            try {
                                Class.forName("org.mariadb.jdbc.Driver");
                                conCliente = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
                                PreparedStatement stmtCliente = conCliente.prepareStatement(
                                    "SELECT rg, nome_do_cliente FROM cadastro_de_clientes ORDER BY nome_do_cliente");
                                ResultSet rsCliente = stmtCliente.executeQuery();
                                while (rsCliente.next()) {
                                    String selected = "";
                                    if (isEdit && rsCliente.getString("rg").equals(pedidoData.get("cliente_rg"))) {
                                        selected = "selected";
                                    }
                        %>
                                <option value="<%= rsCliente.getString("rg") %>" <%= selected %>>
                                    <%= rsCliente.getString("nome_do_cliente") %>
                                </option>
                        <%
                                }
                            } catch (Exception e) {
                                out.print("<div class='message error'>Erro ao carregar clientes: " + e.getMessage() + "</div>");
                            } finally {
                                if (conCliente != null) try { conCliente.close(); } catch (SQLException e) {}
                            }
                        %>
                    </select>
                    <div id="cliente_info"></div>
                </div>

                <div class="form-group">
                    <label>Data de Entrega:</label>
                    <input type="date" name="data_pedido" class="form-control" 
                           value="<%= isEdit && pedidoData.get("data_pedido") != null ? 
                                   sdf.format(pedidoData.get("data_pedido")) : sdf.format(new java.util.Date()) %>" required>
                </div>

                <div class="form-group">
                    <label>Data de Atendimento:</label>
                    <input type="date" name="data_atende" class="form-control" 
                           value="<%= isEdit && pedidoData.get("data_atende") != null ? 
                                   sdf.format(pedidoData.get("data_atende")) : sdf.format(new java.util.Date()) %>" required>
                </div>

                <div class="form-group">
                    <label>Mostruário:</label>
                    <select name="mostruario" class="form-control" required>
                        <option value="N" <%= isEdit && "N".equals(pedidoData.get("mostruario")) ? "selected" : "" %>>Não</option>
                        <option value="S" <%= isEdit && "S".equals(pedidoData.get("mostruario")) ? "selected" : "" %>>Sim</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Observações:</label>
                    <textarea name="observacoes" class="form-control" rows="3"><%= isEdit ? pedidoData.get("observacoes") : "" %></textarea>
                </div>

                <div class="table-responsive">
                    <table id="itens">
                        <thead>
                            <tr>
                                <th>Produto</th>
                                <th>Quantidade</th>
                                <th>Preço Unitário</th>
                                <th>Desconto</th>
                                <th>Preço de Venda</th>
                                <th>Subtotal</th>
                                <th>Ação</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (isEdit && !itensPedido.isEmpty()) { 
                                for (Map<String, Object> item : itensPedido) { %>
                                    <tr>
                                        <td>
                                            <select name="produto_id[]" class="form-control" onchange="atualizarPreco(this)" required>
                                                <option value="">-- Selecione --</option>
                                                <% for (Map<String, Object> produto : todosProdutos) { 
                                                    String selected = (int)item.get("produto_id") == (int)produto.get("codigo") ? "selected" : "";
                                                %>
                                                    <option value="<%= produto.get("codigo") %>" 
                                                            data-preco="<%= produto.get("preco") %>"
                                                            <%= selected %>>
                                                        <%= produto.get("nome") %>
                                                    </option>
                                                <% } %>
                                            </select>
                                        </td>
                                        <td>
                                            <input type="number" name="quantidade[]" class="form-control quantidade" 
                                                   oninput="calcularSubtotal(this)" min="1" 
                                                   value="<%= item.get("quantidade") %>" required>
                                        </td>
                                        <td>
                                            <input type="text" class="form-control preco" 
                                                   value="<%= item.get("preco_unitario") %>" readonly>
                                        </td>
                                        <td>
                                            <input type="number" name="desconto[]" class="form-control desconto" 
                                                   step="0.01" min="0" oninput="calcularPrecoVenda(this)"
                                                   value="<%= item.get("desconto") %>">
                                        </td>
                                        <td>
                                            <input type="text" class="form-control preco_venda" 
                                                   value="<%= String.format("%.2f", (double)item.get("preco_de_venda")) %>" readonly>
                                        </td>
                                        <td>
                                            <input type="text" name="subtotal[]" class="form-control subtotal" 
                                                   value="<%= String.format("%.2f", (int)item.get("quantidade") * (double)item.get("preco_de_venda")) %>" readonly>
                                        </td>
                                        <td>
                                            <button type="button" class="btn btn-danger" onclick="removerItem(this)">Remover</button>
                                        </td>
                                    </tr>
                            <%  } 
                            } else { %>
                                <tr>
                                    <td>
                                        <select name="produto_id[]" class="form-control" onchange="atualizarPreco(this)" required>
                                            <option value="">-- Selecione --</option>
                                            <% for (Map<String, Object> produto : todosProdutos) { %>
                                                <option value="<%= produto.get("codigo") %>" 
                                                        data-preco="<%= produto.get("preco") %>">
                                                    <%= produto.get("nome") %>
                                                </option>
                                            <% } %>
                                        </select>
                                    </td>
                                    <td>
                                        <input type="number" name="quantidade[]" class="form-control quantidade" 
                                               oninput="calcularSubtotal(this)" min="1" value="1" required>
                                    </td>
                                    <td>
                                        <input type="text" class="form-control preco" readonly>
                                    </td>
                                    <td>
                                        <input type="number" name="desconto[]" class="form-control desconto" 
                                               step="0.01" min="0" oninput="calcularPrecoVenda(this)" value="0">
                                    </td>
                                    <td>
                                        <input type="text" class="form-control preco_venda" readonly>
                                    </td>
                                    <td>
                                        <input type="text" name="subtotal[]" class="form-control subtotal" readonly>
                                    </td>
                                    <td>
                                        <button type="button" class="btn btn-danger" onclick="removerItem(this)">Remover</button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="form-group">
                    <button type="button" class="btn" onclick="adicionarItem()">
                        Adicionar Item
                    </button>
                </div>

                <div class="total">
                    <strong>TOTAL DO PEDIDO:</strong> R$ <span id="totalPedido">0.00</span>
                </div>

                <div class="action-buttons">
                    <% if (isEdit) { %>
                        <button type="button" class="btn" onclick="abrirVencimentos()">
                            Gerenciar Vencimentos
                        </button>
                    <% } else { %>
                        <button type="button" class="btn" onclick="salvarEAbrirVencimentos()">
                            Salvar e Abrir Vencimentos
                        </button>
                    <% } %>
                </div>
            </form>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <script>
        // Função para validar o formulário antes de enviar
        function validarFormulario() {
            const clienteSelect = document.getElementById('cliente_rg');
            
            if (clienteSelect.value === "") {
                alert('Por favor, selecione um cliente antes de salvar o pedido.');
                document.getElementById('cliente_search').focus();
                document.getElementById('cliente_search').style.borderColor = 'red';
                setTimeout(() => {
                    document.getElementById('cliente_search').style.borderColor = '';
                }, 2000);
                return false;
            }
            return true;
        }

        // Executar ao carregar a página
        $(document).ready(function() {
            // Configuração do autocomplete
            $("#cliente_search").autocomplete({
                source: function(request, response) {
                    $.ajax({
                        url: "buscar_clientes.jsp",
                        dataType: "json",
                        data: {
                            term: request.term
                        },
                        success: function(data) {
                            response($.map(data, function(item) {
                                return {
                                    label: item.nome,
                                    value: item.nome,
                                    id: item.rg
                                };
                            }));
                        },
                        error: function(xhr, status, error) {
                            console.error("Erro na busca de clientes:", error);
                        }
                    });
                },
                minLength: 2,
                select: function(event, ui) {
                    $("#cliente_rg").val(ui.item.id);
                    $("#cliente_info").text("Cliente selecionado: " + ui.item.label);
                    return false;
                },
                focus: function(event, ui) {
                    event.preventDefault();
                }
            });
            
            // Se estiver editando, mostra o nome do cliente selecionado
            <% if (isEdit) { %>
                $("#cliente_info").text("Cliente selecionado: " + "<%= pedidoData.get("cliente_nome") %>");
            <% } %>

            // Atualizar preços e calcular totais para itens existentes
            const selects = document.querySelectorAll('select[name="produto_id[]"]');
            selects.forEach(select => {
                if (select.value) {
                    atualizarPreco(select);
                }
            });
            calcularTotal();
        });

        function atualizarPreco(select) {
            const row = select.closest('tr');
            const selectedOption = select.selectedOptions[0];
            if (selectedOption && selectedOption.getAttribute("data-preco")) {
                const preco = parseFloat(selectedOption.getAttribute("data-preco"));
                row.querySelector('.preco').value = preco.toFixed(2);
                // Atualiza o preço de venda considerando o desconto atual
                calcularPrecoVenda(row.querySelector('.desconto'));
            }
        }

        function calcularPrecoVenda(input) {
            const row = input.closest('tr');
            const preco = parseFloat(row.querySelector('.preco').value) || 0;
            const desconto = parseFloat(input.value) || 0;
            const precoVenda = preco - desconto;
            row.querySelector('.preco_venda').value = precoVenda.toFixed(2);
            calcularSubtotal(row.querySelector('.quantidade'));
        }

        function calcularSubtotal(input) {
            const row = input.closest('tr');
            const quantidade = parseFloat(input.value) || 0;
            const precoVenda = parseFloat(row.querySelector('.preco_venda').value) || 0;
            const subtotal = quantidade * precoVenda;
            row.querySelector('.subtotal').value = subtotal.toFixed(2);
            calcularTotal();
        }

        function calcularTotal() {
            const subtotais = document.querySelectorAll('.subtotal');
            let total = 0;
            subtotais.forEach(input => {
                total += parseFloat(input.value) || 0;
            });
            document.getElementById('totalPedido').textContent = total.toFixed(2);
        }

        function adicionarItem() {
            const tabela = document.getElementById('itens');
            const novaLinha = tabela.rows[tabela.rows.length - 1].cloneNode(true);
            
            // Limpar valores
            novaLinha.querySelector('select').selectedIndex = 0;
            novaLinha.querySelector('.quantidade').value = '1';
            novaLinha.querySelector('.preco').value = '';
            novaLinha.querySelector('.desconto').value = '0';
            novaLinha.querySelector('.preco_venda').value = '';
            novaLinha.querySelector('.subtotal').value = '';
            
            // Adicionar eventos
            novaLinha.querySelector('select').onchange = function() {
                atualizarPreco(this);
            };
            
            novaLinha.querySelector('.quantidade').oninput = function() {
                calcularSubtotal(this);
            };
            
            novaLinha.querySelector('.desconto').oninput = function() {
                calcularPrecoVenda(this);
            };
            
            tabela.querySelector('tbody').appendChild(novaLinha);
        }

        function removerItem(btn) {
            const tabela = document.getElementById('itens');
            if (tabela.rows.length > 2) { // Mantém pelo menos uma linha
                btn.closest('tr').remove();
                calcularTotal();
            } else {
                alert('O pedido deve ter pelo menos um item.');
            }
        }

        function abrirVencimentos() {
            const pedidoId = new URLSearchParams(window.location.search).get('pedido_id');
            if (pedidoId) {
                window.open('form_vencimentos.jsp?pedido_id=' + pedidoId, 'Vencimentos', 'width=600,height=500');
            } else {
                alert('Salve o pedido primeiro para gerenciar vencimentos');
            }
        }

        function salvarEAbrirVencimentos() {
            if (validarFormulario()) {
                const form = document.querySelector('form');
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'abrir_vencimentos';
                input.value = 'true';
                form.appendChild(input);
                form.submit();
            }
        }
    </script>
</body>
</html>