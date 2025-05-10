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

        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            background-color: #f9f9f9;
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
            margin-left: 10px;
            border: none;
            border-radius: 4px;
            text-decoration: none;
            cursor: pointer;
            font-size: 0.9rem;
        }

        .dashboard {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 20px;
            padding: 40px 20px;
        }

        .dashboard-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            width: 200px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }

        .dashboard-icon {
            font-size: 2rem;
            color: var(--primary-color);
            margin-bottom: 10px;
        }

        .dashboard-title {
            font-size: 1.1rem;
            color: var(--secondary-color);
            margin-bottom: 10px;
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
        Usuário: <strong><%= usuario %></strong> | Nível: <%= permissao %>
    </div>
    <h1><i class="fas fa-home"></i> Menu Principal</h1>
    <div class="actions">
        <a href="logout.jsp" class="btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</header>

    <div class="dashboard-card">
        <div class="dashboard-icon"><i class="fas fa-users"></i></div>
        <div class="dashboard-title">Usuários</div>
        <a href="cadastrar_usuario.jsp" class="btn">Cadastrar Usuários</a>
    </div>

    <div class="dashboard-card">
        <div class="dashboard-icon"><i class="fas fa-users"></i></div>
        <div class="dashboard-title">Usuários</div>
        <a href="lista_usuarios.jsp" class="btn">Usuários Cadastrados</a>
    </div>


    <% if (permissao == 1) { %>
    <div class="dashboard-card">
        <div class="dashboard-icon"><i class="fas fa-database"></i></div>
        <div class="dashboard-title">Backup Banco</div>
        <form action="backup.jsp" method="post">
            <button type="submit" class="btn">Fazer Backup</button>
        </form>
    </div>
    <% } %>

</div>
    <a href="index.jsp"><i class="fas fa-arrow-left"></i> Voltar</a>

<footer>
    
    <p><i class="fas fa-quote-left"></i> Se você pode sonhar, você pode realizar. <i class="fas fa-quote-right"></i></p>
</footer>

</body>
</html>
