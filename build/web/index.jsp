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
                position: relative;
            }

            .user-info {
                position: absolute;
                top: 1.5rem;
                left: 2rem;
                font-size: 0.95rem;
                background: rgba(255, 255, 255, 0.1);
                padding: 0.5rem 1rem;
                border-radius: 20px;
                display: flex;
                align-items: center;
                gap: 0.5rem;
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

            main {
                flex: 1;
                padding: 2rem;
                max-width: 1200px;
                margin: 0 auto;
                width: 100%;
            }

            .welcome-message {
                font-size: 1.5rem;
                color: var(--dark-color);
                margin-bottom: 2rem;
                font-weight: 400;
            }

            .button-row {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
                gap: 1.5rem;
                margin-top: 2rem;
            }

            .menu-btn {
                background-color: white;
                color: var(--dark-color);
                padding: 1.5rem;
                border-radius: var(--border-radius);
                text-decoration: none;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 0.8rem;
                transition: var(--transition);
                box-shadow: var(--shadow-sm);
                border-top: 4px solid var(--secondary-color);
                text-align: center;
                height: 100%;
            }

            .menu-btn:hover {
                transform: translateY(-5px);
                box-shadow: var(--shadow-md);
                background-color: var(--light-color);
            }

            .menu-btn i {
                font-size: 2rem;
                color: var(--secondary-color);
            }

            .menu-btn span {
                font-weight: 500;
                font-size: 1rem;
            }

            .admin-btn {
                border-top-color: var(--accent-color);
            }

            .admin-btn i {
                color: var(--accent-color);
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

            @media (max-width: 768px) {
                header {
                    padding: 1rem;
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                }

                .user-info, .actions {
                    position: static;
                    width: 100%;
                    justify-content: center;
                }

                .button-row {
                    grid-template-columns: 1fr 1fr;
                }
            }

            @media (max-width: 480px) {
                .button-row {
                    grid-template-columns: 1fr;
                }

                .menu-btn {
                    padding: 1.2rem;
                }
            }
        </style>
    </head>
    <body>
        <header>
            <div class="user-info">
                <i class="fas fa-user-circle"></i>
                <span><%= usuario%> | Nível <%= permissao%></span>
            </div>
            <h1><i class="fas fa-home"></i> Menu Principal</h1>
            <div class="actions">
                <form action="logout.jsp" method="post" style="display:inline;">
                    <button type="submit" class="btn"><i class="fas fa-sign-out-alt"></i> Sair</button>
                </form>
            </div>
        </header>

        <main>
            <h2 class="welcome-message">Bem-vindo ao Sistema Rosbea</h2>
            <div class="button-row">
                <%-- Exibe para digitador --%>
                <% if (permissao == 2 || permissao == 3) { %>
                <a href="novos_pedidos.html" class="menu-btn">
                    <i class="fas fa-shopping-cart"></i>
                    <span>Pedidos</span>
                </a>
                <% } %>

                <% if (permissao == 2 || permissao == 3) { %>
                <a href="dados_produto.html" class="menu-btn">
                    <i class="fas fa-box-open"></i>
                    <span>Produtos</span>
                </a>
                <% } %>


                <%-- Acesso a clientes: exemplo de uso para digitadores e superiores --%>
                <% if (permissao == 2 || permissao == 3) { %>
                <a href="clientes.html" class="menu-btn">
                    <i class="fas fa-users"></i>
                    <span>Clientes</span>
                </a>              

                <% } %>


                <% if (permissao == 2 || permissao == 1) { %>
                <a href="relatorios.html" class="menu-btn">
                    <i class="fas fa-chart-bar"></i>
                    <span>Relatórios</span>
                </a>
                <% } %>



                <% if (permissao == 2 || permissao == 1) { %>
                <a href="gerencia_geral.html" class="menu-btn">
                    <i class="fas fa-chart-bar"></i>
                    <span>Gerencia</span>
                </a>
                <% } %>

                <% if (permissao == 2 || permissao == 1) { %>
                <a href="caixa.jsp" class="menu-btn admin-btn">
                    <i class="fas fa-money-bill-wave"></i>
                    <span>caixa</span>
                </a>
                <% } %>

                <%-- Acesso a área administrativa (apenas admin) --%>
                <% if (permissao == 1) { %>
                <a href="gerenciar_pedidos.html" class="menu-btn admin-btn">
                    <i class="fas fa-clipboard-list"></i>
                    <span>Gerenciar Pedidos</span>
                </a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="gerenciar_produtos.html" class="menu-btn admin-btn">
                    <i class="fas fa-boxes"></i>
                    <span>Gerenciar Produtos</span>
                </a>
                <% } %>


                <% if (permissao == 2 || permissao == 1) { %>
                <a href="editar_vencimento.jsp" class="menu-btn">
                    <i class="fas fa-shopping-cart"></i>
                    <span>Editar Vencimentos</span>
                </a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="gerenciar_clientes.html" class="menu-btn admin-btn">
                    <i class="fas fa-user-cog"></i>
                    <span>Gerenciar Clientes</span>
                </a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="financeiro.html" class="menu-btn admin-btn">
                    <i class="fas fa-money-bill-wave"></i>
                    <span>Financeiro</span>
                </a>
                <% } %>

                <% if (permissao == 2 || permissao == 1) { %>
                <a href="compra_form.html" class="menu-btn">
                    <i class="fas fa-cart-plus"></i>
                    <span>Compras</span>
                </a>               

                <% } %>

                <% if (permissao == 2 || permissao == 1) { %>
                <a href="relatorios.html" class="menu-btn">
                    <i class="fas fa-chart-bar"></i>
                    <span>Relatórios</span>
                </a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="cadastro_fornecedor.html" class="menu-btn admin-btn">
                    <i class="fas fa-truck"></i>
                    <span>Cadastro de Fornecedor</span>
                </a>
                <% } %>

                <% if (permissao == 1) { %>
                <a href="painel_admin.jsp" class="menu-btn admin-btn">
                    <i class="fas fa-tools"></i>
                    <span>Painel Admin</span>
                </a>
                <% }%>
            </div>
        </main>

        <footer>
            <p><i class="fas fa-quote-left"></i> Se você pode sonhar, você pode realizar. <i class="fas fa-quote-right"></i></p>
        </footer>
    </body>
</html>