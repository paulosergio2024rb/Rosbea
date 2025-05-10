<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Processamento de Cadastro</title>
</head>
<body>
    <%
        // Dados de conexão com o banco de dados
        String url = "jdbc:mariadb://localhost:3306/Rosbea";
        String usuario = "paulo";
        String senha = "6421";
        
        Connection conexao = null;
        PreparedStatement stmt = null;
        
        try {
            // Carregar o driver JDBC
            Class.forName("org.mariadb.jdbc.Driver");
            
            // Estabelecer conexão com o banco de dados
            conexao = DriverManager.getConnection(url, usuario, senha);
            
            // Preparar a declaração SQL
            String sql = "INSERT INTO fornecedores (fornecedor, endereco, nr, bairro, cidade, telefone, email) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
            
            stmt = conexao.prepareStatement(sql);
            
            // Definir os parâmetros
            stmt.setString(1, request.getParameter("fornecedor"));
            stmt.setString(2, request.getParameter("endereco"));
            stmt.setString(3, request.getParameter("nr"));
            stmt.setString(4, request.getParameter("bairro"));
            stmt.setString(5, request.getParameter("cidade"));
            stmt.setString(6, request.getParameter("telefone"));
            stmt.setString(7, request.getParameter("email"));
            
            // Executar a inserção
            int linhasAfetadas = stmt.executeUpdate();
            
            if (linhasAfetadas > 0) {
                out.println("<h2>Fornecedor cadastrado com sucesso!</h2>");
                out.println("<a href='cadastro_fornecedor.html'>Cadastrar novo fornecedor</a>");
            } else {
                out.println("<h2 style='color:red;'>Erro ao cadastrar fornecedor.</h2>");
                out.println("<a href='cadastro_fornecedor.html'>Tentar novamente</a>");
            }
            
        } catch (ClassNotFoundException e) {
            out.println("<h2 style='color:red;'>Driver JDBC não encontrado.</h2>");
            e.printStackTrace();
        } catch (SQLException e) {
            out.println("<h2 style='color:red;'>Erro de SQL: " + e.getMessage() + "</h2>");
            e.printStackTrace();
        } finally {
            // Fechar recursos
            if (stmt != null) {
                try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
            if (conexao != null) {
                try { conexao.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    %>
</body>
</html>