<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
// Obter parâmetros do formulário
String userId = request.getParameter("id");
String nomeUsuario = request.getParameter("nome_usuario");
String senha = request.getParameter("senha");
String permissaoAcesso = request.getParameter("permissao_acesso");

// Validar dados
if (nomeUsuario == null || nomeUsuario.isEmpty() || 
    senha == null || senha.isEmpty() || 
    permissaoAcesso == null || permissaoAcesso.isEmpty()) {
    response.sendRedirect("editar_usuario.jsp?id=" + userId + "&error=Dados incompletos");
    return;
}

Connection con = null;
PreparedStatement stmt = null;

try {
    Class.forName("org.mariadb.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
    
    String sql = "UPDATE usuarios SET nome_usuario = ?, senha = ?, permissao_acesso = ? WHERE id = ?";
    stmt = con.prepareStatement(sql);
    stmt.setString(1, nomeUsuario);
    stmt.setString(2, senha);
    stmt.setInt(3, Integer.parseInt(permissaoAcesso));
    stmt.setInt(4, Integer.parseInt(userId));
    
    int rowsAffected = stmt.executeUpdate();
    
    if (rowsAffected > 0) {
        response.sendRedirect("editar_usuario.jsp?id=" + userId + "&success=Usuário atualizado com sucesso");
    } else {
        response.sendRedirect("editar_usuario.jsp?id=" + userId + "&error=Nenhum usuário foi atualizado");
    }
} catch (Exception e) {
    response.sendRedirect("editar_usuario.jsp?id=" + userId + "&error=Erro ao atualizar usuário: " + e.getMessage());
} finally {
    if (stmt != null) stmt.close();
    if (con != null) con.close();
}
%>