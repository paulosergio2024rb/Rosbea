<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer permissao = (Integer) session.getAttribute("permissao");
    String usuario = (String) session.getAttribute("usuario");

    if (usuario == null || permissao == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Menu Principal - Sistema Rosbea</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #4a6fa5;
                --secondary-color: #166088;
                --accent-color: #4fc3f7;
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f9f9f9;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }

            header {
                background-color: var(--primary-color);
                color: white;
                padding: 20px;
                text-align: center;
                position: relative;
            }

            .user-info {
                position: absolute;
                top: 20px;
                left: 20px;
                font-size: 0.9rem;
            }

            .actions {
                position: absolute;
                top: 20px;
                right: 20px;
            }

            .btn {
                background-color: var(--secondary-color);
                color: white;
                padding: 8px 14px;
                margin: 0 5px;
                border: none;
                border-radius: 4px;
                text-decoration: none;
                cursor: pointer;
                font-size: 0.9rem;
            }

            main {
                flex: 1;
                padding: 40px 20px;
                text-align: center;
            }

            .button-row {
                display: flex;
                justify-content: center;
                gap: 20px;
                margin-top: 40px;
                flex-wrap: wrap;
            }

            footer {
                background-color: var(--primary-color);
                color: white;
                text-align: center;
                padding: 10px;
            }
        </style>
    </head>
    <body>
        <header>

            <div class="user-info">
                Usuário: <strong><%= usuario%></strong> | Nível: <%= permissao%>
            </div>
            <h1>Menu Principal</h1>
            <div class="actions">
                <form action="logout.jsp" method="post" style="display:inline;">
                    <button type="submit" class="btn"><i class="fas fa-sign-out-alt"></i> Logout</button>
                </form>
            </div>

        </header>

        <main>
            <h2>Bem-vindo ao Sistema Rosbea</h2>
            <div class="button-row">
                <%-- Exibe para digitador --%>
                <% if (permissao == 2 || permissao == 3) { %>
                <a href="novos_pedidos.html" class="btn"><i class="fas fa-shopping-cart"></i> Pedidos</a>
                <% } %>
                
                <% if (permissao == 2 || permissao == 3) { %>
                <a href="dados_produto.html" class="btn"><i class="fas fa-box-open"></i> Produtos</a>
                <% } %>

                <%-- Acesso a clientes: exemplo de uso para digitadores e superiores --%>
                <% if (permissao == 2 || permissao == 3) { %>
                <a href="clientes.html" class="btn"><i class="fas fa-users"></i> Clientes</a>
                <% } %>

                <% if (permissao == 2 || permissao == 1) { %>
                <a href="relatorios.html" class="btn"><i class="fas fa-users"></i> Relatórios</a>
                <% } %>
                <% if (permissao == 1) { %>
                <a href="lista_usuarios.jsp" class="btn"><i class="fas fa-users"></i> Lista de Usuarios</a>
                <% } %>


                <%-- Acesso a área administrativa (apenas admin) --%>

                <% if (permissao == 1) { %>
                <a href="gerenciar_pedidos.html" class="btn"><i class="fas fa-tools"></i> Gerenciar Pedidos</a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="gerenciar_produtos.html" class="btn"><i class="fas fa-tools"></i> Gerenciar Produtos</a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="gerenciar_clientes.html" class="btn"><i class="fas fa-tools"></i> Gerenciar Clientes</a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="financeiro.html" class="btn"><i class="fas fa-tools"></i> Financeiro</a>
                <% } %>

                <% if (permissao == 2 || permissao == 1) { %>
                <a href="compra_form.html" class="btn"><i class="fas fa-users"></i> Compras</a>
                <% } %>

                <% if (permissao == 2 || permissao == 1) { %>
                <a href="caixa.jsp" class="btn"><i class="fas fa-users"></i> Caixa</a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="fornecedor.html" class="btn"><i class="fas fa-users"></i> Fornecedor</a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="painel_admin.jsp" class="btn"><i class="fas fa-tools"></i> Painel Admin</a>
                <% }%>
            </div>
        </main>

        <footer>
            <p><i class="fas fa-quote-left"></i> Se você pode sonhar, você pode realizar. <i class="fas fa-quote-right"></i></p>
        </footer>
    </body>
</html>
