<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // Informações de conexão com o banco de dados
    String dbURL = "jdbc:mariadb://localhost:3306/Rosbea";
    String dbUser = "paulo";
    String dbPassword = "6421";
    Connection conn = null;
    PreparedStatement pstmt = null;
    String mensagem = null;
    boolean sucesso = false;

    try {
        // Obtém o ID do usuário a ser excluído do formulário POST
        String idParaExcluir = request.getParameter("id");

        if (idParaExcluir != null && !idParaExcluir.isEmpty()) {
            int id = Integer.parseInt(idParaExcluir);

            // Conecta ao banco de dados
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

            // Prepara a consulta SQL para excluir o usuário
            String sql = "DELETE FROM usuarios WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);

            int linhasAfetadas = pstmt.executeUpdate();

            if (linhasAfetadas > 0) {
                mensagem = "Usuário excluído com sucesso!";
                sucesso = true;
            } else {
                mensagem = "Erro ao excluir o usuário. Usuário não encontrado.";
            }
        } else {
            mensagem = "ID do usuário para exclusão não fornecido.";
        }

    } catch (SQLException e) {
        mensagem = "Erro ao acessar o banco de dados: " + e.getMessage();
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        mensagem = "Driver do banco de dados não encontrado: " + e.getMessage();
        e.printStackTrace();
    } finally {
        // Fecha as conexões no bloco finally
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Excluir Usuário</title>
    <style>
        body {
            font-family: sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }

        .container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 400px;
            text-align: center;
        }

        h1 {
            color: #dc3545;
            margin-bottom: 20px;
        }

        p {
            margin-bottom: 15px;
        }

        .success {
            color: green;
            font-weight: bold;
        }

        .error {
            color: red;
            font-weight: bold;
        }

        a {
            color: #007bff;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Excluir Usuário</h1>
        <% if (mensagem != null) { %>
            <p class="<%= sucesso ? "success" : "error" %>"><%= mensagem %></p>
        <% } %>
        <p><a href="lista_usuarios.jsp">Voltar para a lista de usuários</a></p>
    </div>
</body>
</html>