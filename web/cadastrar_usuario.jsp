<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cadastrar Novo Usuário</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f2f2f2; padding: 30px; }
        .container { background: white; padding: 20px; max-width: 500px; margin: auto; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h2 { text-align: center; color: #333; }
        form { display: flex; flex-direction: column; }
        label { margin-top: 10px; }
        input, select, button { padding: 10px; margin-top: 5px; }
        .btn { background: #007bff; color: white; border: none; cursor: pointer; margin-top: 20px; }
        .btn:hover { background: #0056b3; }
        .btn-back { background: #6c757d; }
        .alert { padding: 10px; margin-top: 15px; border-radius: 5px; }
        .success { background-color: #d4edda; color: #155724; }
        .error { background-color: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
<div class="container">
    <h2>Cadastrar Novo Usuário</h2>
    <form method="post">
        <label>Nome de Usuário:</label>
        <input type="text" name="nome_usuario" required>

        <label>Senha:</label>
        <input type="password" name="senha" required>

        <label>Nível de Acesso:</label>
        <select name="permissao_acesso" required>
            <option value="">-- Selecione --</option>
            <option value="1">Administrador</option>
            <option value="2">Gerente</option>
            <option value="3">Digitador</option>
            <option value="4">Visitante</option>
        </select>

        <button type="submit" class="btn">Cadastrar</button>
        <a href="painel_admin.jsp"><button type="button" class="btn btn-back">Voltar</button></a>
    </form>

    <%
        if (request.getMethod().equalsIgnoreCase("post")) {
            String nome = request.getParameter("nome_usuario");
            String senha = request.getParameter("senha");
            String permissao = request.getParameter("permissao_acesso");

            try {
                Class.forName("org.mariadb.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

                PreparedStatement check = conn.prepareStatement("SELECT COUNT(*) FROM usuarios WHERE nome_usuario = ?");
                check.setString(1, nome);
                ResultSet rs = check.executeQuery();
                rs.next();
                if (rs.getInt(1) > 0) {
                    out.println("<div class='alert error'>Usuário já existe!</div>");
                } else {
                    PreparedStatement stmt = conn.prepareStatement("INSERT INTO usuarios (nome_usuario, senha, permissao_acesso) VALUES (?, ?, ?)");
                    stmt.setString(1, nome);
                    stmt.setString(2, senha);
                    stmt.setInt(3, Integer.parseInt(permissao));
                    stmt.executeUpdate();
                    out.println("<div class='alert success'>Usuário cadastrado com sucesso!</div>");
                    stmt.close();
                }
                rs.close();
                check.close();
                conn.close();
            } catch (Exception e) {
                out.println("<div class='alert error'>Erro: " + e.getMessage() + "</div>");
            }
        }
    %>
</div>
</body>
</html>
