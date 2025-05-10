<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    String msg = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nome = request.getParameter("usuario");
        String senha = request.getParameter("senha");

        try {
            Class.forName("org.mariadb.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

            String sql = "SELECT * FROM usuarios WHERE nome_usuario = ? AND senha = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, nome);
            stmt.setString(2, senha);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                session.setAttribute("usuario", rs.getString("nome_usuario"));
                session.setAttribute("permissao", rs.getInt("permissao_acesso"));
                response.sendRedirect("index.jsp");
                return;
            } else {
                msg = "Usuário ou senha inválidos!";
            }

            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            msg = "Erro: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Sistema Rosbea</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #4361ee;
            --secondary-color: #3f37c9;
            --success-color: #4cc9f0;
            --danger-color: #f72585;
            --light-color: #f8f9fa;
            --dark-color: #212529;
            --border-radius: 8px;
            --box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Roboto', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .login-container {
            background: white;
            padding: 40px;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            width: 100%;
            max-width: 380px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .login-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background: var(--primary-color);
        }

        .logo {
            margin-bottom: 25px;
            color: var(--primary-color);
            font-size: 2.5rem;
        }

        h2 {
            text-align: center;
            margin-bottom: 25px;
            color: var(--dark-color);
            font-weight: 500;
        }

        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #555;
        }

        .input-icon {
            position: relative;
        }

        .input-icon i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
        }

        input[type="text"], 
        input[type="password"] {
            width: 100%;
            padding: 12px 12px 12px 40px;
            border: 1px solid #ddd;
            border-radius: var(--border-radius);
            font-family: 'Roboto', sans-serif;
            font-size: 0.95rem;
            transition: all 0.3s;
        }

        input[type="text"]:focus, 
        input[type="password"]:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1);
        }

        button {
            background-color: var(--primary-color);
            color: white;
            padding: 12px;
            width: 100%;
            border: none;
            border-radius: var(--border-radius);
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        button:hover {
            background-color: var(--secondary-color);
            transform: translateY(-2px);
        }

        .mensagem {
            text-align: center;
            color: var(--danger-color);
            margin-top: 15px;
            font-size: 0.9rem;
            padding: 10px;
            border-radius: var(--border-radius);
            background-color: rgba(247, 37, 133, 0.05);
            border-left: 3px solid var(--danger-color);
        }

        .footer {
            margin-top: 25px;
            font-size: 0.8rem;
            color: #777;
        }

        @media (max-width: 480px) {
            .login-container {
                padding: 30px 20px;
            }
            
            .logo {
                font-size: 2rem;
            }
            
            h2 {
                font-size: 1.2rem;
                margin-bottom: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">
            <i class="fas fa-cash-register"></i>
        </div>
        <h2>Acessar Sistema Rosbea</h2>
        <form method="post">
            <div class="form-group">
                <label for="usuario">Usuário</label>
                <div class="input-icon">
                    <i class="fas fa-user"></i>
                    <input type="text" id="usuario" name="usuario" placeholder="Digite seu usuário" required>
                </div>
            </div>
            
            <div class="form-group">
                <label for="senha">Senha</label>
                <div class="input-icon">
                    <i class="fas fa-lock"></i>
                    <input type="password" id="senha" name="senha" placeholder="Digite sua senha" autocomplete="off" required>
                </div>
            </div>
            
            <button type="submit">
                <i class="fas fa-sign-in-alt"></i> Entrar
            </button>
            
            <% if (!msg.isEmpty()) { %>
                <div class="mensagem"><%= msg %></div>
            <% } %>
            
            <div class="footer">
                Sistema de Controle de Caixa - Rosbea
            </div>
        </form>
    </div>
</body>
</html>