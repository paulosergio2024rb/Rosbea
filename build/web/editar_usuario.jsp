<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
// Verificar se há um ID de usuário para edição
String userId = request.getParameter("id");
if (userId == null || userId.isEmpty()) {
    response.sendRedirect("lista_usuarios.jsp");
    return;
}

// Variáveis para armazenar os dados do usuário
String nomeUsuario = "";
String senha = "";
int permissaoAcesso = 0;

// Carregar dados do usuário
Connection conUsuario = null;
PreparedStatement stmtUsuario = null;
ResultSet rsUsuario = null;

try {
    Class.forName("org.mariadb.jdbc.Driver");
    conUsuario = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
    
    String sqlUsuario = "SELECT nome_usuario, senha, permissao_acesso FROM usuarios WHERE id = ?";
    stmtUsuario = conUsuario.prepareStatement(sqlUsuario);
    stmtUsuario.setInt(1, Integer.parseInt(userId));
    rsUsuario = stmtUsuario.executeQuery();
    
    if (rsUsuario.next()) {
        nomeUsuario = rsUsuario.getString("nome_usuario");
        senha = rsUsuario.getString("senha");
        permissaoAcesso = rsUsuario.getInt("permissao_acesso");
    } else {
        response.sendRedirect("lista_usuarios.jsp");
        return;
    }
} catch (Exception e) {
    out.print("<div class='alert error'>Erro ao carregar usuário: " + e.getMessage() + "</div>");
} finally {
    if (rsUsuario != null) rsUsuario.close();
    if (stmtUsuario != null) stmtUsuario.close();
    if (conUsuario != null) conUsuario.close();
}
%>
<html>
<head>
    <title>Editar Usuário</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #3498db;
            --accent-color: #e74c3c;
            --success-color: #27ae60;
            --light-color: #ecf0f1;
            --dark-color: #2c3e50;
            --text-light: #ffffff;
            --text-dark: #333333;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f5f7fa;
            color: var(--text-dark);
            line-height: 1.6;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 30px;
        }

        h1 {
            color: var(--primary-color);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--primary-color);
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            transition: border 0.3s;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }

        select.form-control {
            height: 45px;
        }

        .btn {
            display: inline-block;
            background-color: var(--secondary-color);
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.3s;
            margin-top: 10px;
        }

        .btn:hover {
            background-color: #2980b9;
            transform: translateY(-2px);
        }

        .btn-back {
            background-color: var(--dark-color);
            margin-right: 10px;
        }

        .btn-save {
            background-color: var(--success-color);
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .action-buttons {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }

        .password-toggle {
            position: relative;
        }

        .password-toggle i {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: var(--dark-color);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1><i class="fas fa-user-edit"></i> Editar Usuário</h1>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert error">
                <i class="fas fa-exclamation-circle"></i> <%= request.getParameter("error") %>
            </div>
        <% } %>

        <% if (request.getParameter("success") != null) { %>
            <div class="alert success">
                <i class="fas fa-check-circle"></i> <%= request.getParameter("success") %>
            </div>
        <% } %>

        <form action="atualizar_usuario.jsp" method="post">
            <input type="hidden" name="id" value="<%= userId %>">

            <div class="form-group">
                <label for="nome_usuario">Nome de Usuário:</label>
                <input type="text" id="nome_usuario" name="nome_usuario" class="form-control" 
                       value="<%= nomeUsuario %>" required>
            </div>

            <div class="form-group password-toggle">
                <label for="senha">Senha:</label>
                <input type="password" id="senha" name="senha" class="form-control" 
                       value="<%= senha %>" required>
                <i class="fas fa-eye" id="togglePassword"></i>
            </div>

            <div class="form-group">
                <label for="permissao_acesso">Nível de Acesso:</label>
                <select id="permissao_acesso" name="permissao_acesso" class="form-control" required>
                    <option value="">-- Selecione o nível de acesso --</option>
                    <%
                    Connection conNiveis = null;
                    PreparedStatement stmtNiveis = null;
                    ResultSet rsNiveis = null;
                    
                    try {
                        Class.forName("org.mariadb.jdbc.Driver");
                        conNiveis = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
                        
                        String sqlNiveis = "SELECT id, cargo, nivel FROM niveis_acesso ORDER BY nivel";
                        stmtNiveis = conNiveis.prepareStatement(sqlNiveis);
                        rsNiveis = stmtNiveis.executeQuery();
                        
                        while (rsNiveis.next()) {
                            String selected = (rsNiveis.getInt("nivel") == permissaoAcesso) ? "selected" : "";
                    %>
                            <option value="<%= rsNiveis.getInt("nivel") %>" <%= selected %>>
                                <%= rsNiveis.getString("cargo") %> (Nível <%= rsNiveis.getInt("nivel") %>)
                            </option>
                    <%
                        }
                    } catch (Exception e) {
                        out.print("<div class='alert error'>Erro ao carregar níveis de acesso: " + e.getMessage() + "</div>");
                    } finally {
                        if (rsNiveis != null) rsNiveis.close();
                        if (stmtNiveis != null) stmtNiveis.close();
                        if (conNiveis != null) conNiveis.close();
                    }
                    %>
                </select>
            </div>

            <div class="action-buttons">
                <a href="lista_usuarios.jsp" class="btn btn-back">
                    <i class="fas fa-arrow-left"></i> Voltar
                </a>
                <button type="submit" class="btn btn-save">
                    <i class="fas fa-save"></i> Salvar Alterações
                </button>
            </div>
        </form>
    </div>

    <script>
        // Mostrar/ocultar senha
        const togglePassword = document.querySelector('#togglePassword');
        const password = document.querySelector('#senha');
        
        togglePassword.addEventListener('click', function() {
            const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
            password.setAttribute('type', type);
            this.classList.toggle('fa-eye-slash');
        });
    </script>
</body>
</html>