<%@ page import="java.sql.*, org.json.JSONArray, org.json.JSONObject" %>
<%@ page contentType="application/json;charset=UTF-8" %>
<%
    // Configurações do banco de dados
    String url = "jdbc:mariadb://localhost:3306/Rosbea";
    String user = "paulo";
    String password = "6421";
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    JSONArray fornecedores = new JSONArray();
    
    try {
        // Registrar o driver
        Class.forName("org.mariadb.jdbc.Driver");
        
        // Estabelecer conexão
        conn = DriverManager.getConnection(url, user, password);
        
        // Criar e executar consulta
        stmt = conn.createStatement();
        String sql = "SELECT fornecedor, endereco, nr, bairro, cidade, telefone, email " +
                     "FROM fornecedores ORDER BY fornecedor";
        rs = stmt.executeQuery(sql);
        
        // Processar resultados
        while (rs.next()) {
            JSONObject fornecedor = new JSONObject();
            fornecedor.put("fornecedor", rs.getString("fornecedor"));
            fornecedor.put("endereco", rs.getString("endereco"));
            fornecedor.put("nr", rs.getString("nr"));
            fornecedor.put("bairro", rs.getString("bairro"));
            fornecedor.put("cidade", rs.getString("cidade"));
            fornecedor.put("telefone", rs.getString("telefone"));
            fornecedor.put("email", rs.getString("email"));
            
            fornecedores.put(fornecedor);
        }
        
        out.print(fornecedores.toString());
        
    } catch (Exception e) {
        // Em caso de erro, retornar um JSON com a mensagem de erro
        JSONObject erro = new JSONObject();
        erro.put("erro", e.getMessage());
        out.print(erro.toString());
    } finally {
        // Fechar recursos
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>