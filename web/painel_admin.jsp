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
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            --success-color: #2ecc71;
            --warning-color: #f39c12;
            --text-light: #ffffff;
            --text-dark: #333333;
            --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            background-color: #f5f7fa;
            color: var(--text-dark);
            line-height: 1.6;
        }

        header {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: var(--text-light);
            padding: 1.5rem 2rem;
            text-align: center;
            position: relative;
            box-shadow: var(--shadow);
            z-index: 10;
        }

        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
        }

        .user-info {
            font-size: 0.95rem;
            background: rgba(255, 255, 255, 0.1);
            padding: 0.5rem 1rem;
            border-radius: 20px;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .user-info i {
            color: var(--accent-color);
        }

        .header-title {
            flex: 1;
            text-align: center;
            margin: 0.5rem 0;
        }

        .header-title h1 {
            font-weight: 500;
            font-size: 1.8rem;
        }

        .header-title i {
            margin-right: 0.5rem;
            color: var(--light-color);
        }

        .actions {
            display: flex;
            gap: 0.5rem;
        }

        .btn {
            background-color: var(--accent-color);
            color: var(--text-light);
            padding: 0.6rem 1.2rem;
            border: none;
            border-radius: 30px;
            text-decoration: none;
            cursor: pointer;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: var(--transition);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        .btn i {
            font-size: 0.9rem;
        }

        .main-content {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .dashboard {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1.5rem;
            padding: 1rem 0;
        }

        .dashboard-card {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: var(--shadow);
            text-align: center;
            transition: var(--transition);
            border-top: 4px solid var(--secondary-color);
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }

        .dashboard-icon {
            font-size: 2.5rem;
            color: var(--secondary-color);
            margin-bottom: 1rem;
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(52, 152, 219, 0.1);
            border-radius: 50%;
        }

        .dashboard-title {
            font-size: 1.2rem;
            color: var(--dark-color);
            margin-bottom: 1rem;
            font-weight: 500;
        }

        .dashboard-card .btn {
            margin-top: auto;
            width: 100%;
            justify-content: center;
            background-color: var(--secondary-color);
        }

        .dashboard-card .btn:hover {
            background-color: #2980b9;
        }

        .admin-only {
            border-top-color: var(--accent-color);
        }

        .admin-only .dashboard-icon {
            color: var(--accent-color);
            background: rgba(231, 76, 60, 0.1);
        }

        .admin-only .btn {
            background-color: var(--accent-color);
        }

        .admin-only .btn:hover {
            background-color: #c0392b;
        }

        .back-link {
            display: inline-block;
            margin: 2rem 0;
            color: var(--secondary-color);
            text-decoration: none;
            font-weight: 500;
            transition: var(--transition);
        }

        .back-link:hover {
            color: var(--primary-color);
            text-decoration: underline;
        }

        .back-link i {
            margin-right: 0.5rem;
        }

        footer {
            background: var(--dark-color);
            color: var(--text-light);
            text-align: center;
            padding: 1.5rem;
            margin-top: 3rem;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
        }

        .footer-quote {
            font-style: italic;
            opacity: 0.8;
            margin-bottom: 0.5rem;
        }

        .footer-copyright {
            font-size: 0.9rem;
            opacity: 0.7;
        }

        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: 1rem;
            }

            .user-info, .actions {
                position: static;
                width: 100%;
                justify-content: center;
            }

            .header-title h1 {
                font-size: 1.5rem;
            }

            .dashboard {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .btn {
                padding: 0.5rem 1rem;
                font-size: 0.8rem;
            }

            .dashboard-card {
                padding: 1.2rem;
            }
        }
    </style>
</head>
<body>

<header>
    <div class="header-content">
        <div class="user-info">
            <i class="fas fa-user-circle"></i>
            <span><%= usuario %> | Nível <%= permissao %></span>
        </div>
        
        <div class="header-title">
            <h1><i class="fas fa-home"></i> Painel de Controle</h1>
        </div>
        
        <div class="actions">
            <a href="logout.jsp" class="btn">
                <i class="fas fa-sign-out-alt"></i> Sair
            </a>
        </div>
    </div>
</header>

<main class="main-content">
    <div class="dashboard">
        <div class="dashboard-card">
            <div class="dashboard-icon"><i class="fas fa-user-plus"></i></div>
            <div class="dashboard-title">Cadastrar Usuários</div>
            <a href="cadastrar_usuario.jsp" class="btn">
                <i class="fas fa-plus-circle"></i> Novo Usuário
            </a>
        </div>

        <div class="dashboard-card">
            <div class="dashboard-icon"><i class="fas fa-users"></i></div>
            <div class="dashboard-title">Gerenciar Usuários</div>
            <a href="lista_usuarios.jsp" class="btn">
                <i class="fas fa-list"></i> Ver Todos
            </a>
        </div>

        <% if (permissao == 1) { %>
        <div class="dashboard-card admin-only">
            <div class="dashboard-icon"><i class="fas fa-database"></i></div>
            <div class="dashboard-title">Backup do Sistema</div>
            <form action="backup.jsp" method="post" style="width: 100%;">
                <button type="submit" class="btn">
                    <i class="fas fa-save"></i> Executar Backup
                </button>
            </form>
        </div>
        <% } %>
    </div>

    <a href="index.jsp" class="back-link">
        <i class="fas fa-arrow-left"></i> Voltar para página inicial
    </a>
</main>

<footer>
    <div class="footer-content">
        <p class="footer-quote">
            <i class="fas fa-quote-left"></i> Se você pode sonhar, você pode realizar. <i class="fas fa-quote-right"></i>
        </p>
        <p class="footer-copyright">
            Sistema Rosbea &copy; <%= java.time.Year.now().getValue() %>
        </p>
    </div>
</footer>

</body>
</html>