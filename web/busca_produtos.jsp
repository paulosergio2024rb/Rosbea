<%@ page import="java.sql.*, org.json.JSONArray, org.json.JSONObject" %>
<%@ page contentType="application/json;charset=UTF-8" %>
<%
    // Configurações do banco de dados
    String url = "jdbc:mariadb://localhost:3306/Rosbea";
    String user = "paulo";
    String password = "6421";
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    JSONArray produtos = new JSONArray();
    
    try {
        // Registrar o driver
        Class.forName("org.mariadb.jdbc.Driver");
        
        // Estabelecer conexão
        conn = DriverManager.getConnection(url, user, password);
        
        // Criar e executar consulta
        String sql = "SELECT codigo, nome, inspirado, preco, preco_de_custo, " +
                     "preco_dolar, embalagem FROM produto " +
                     "WHERE ativo = 'sim' ORDER BY nome, marca";
        
        stmt = conn.prepareStatement(sql);
        rs = stmt.executeQuery();
        
        // Processar resultados
        while (rs.next()) {
            JSONObject produto = new JSONObject();
            produto.put("codigo", rs.getInt("codigo"));
            produto.put("nome", rs.getString("nome"));
            produto.put("inspirado", rs.getString("inspirado"));
            produto.put("preco", rs.getDouble("preco"));
            produto.put("preco_de_custo", rs.getDouble("preco_de_custo"));
            produto.put("preco_dolar", rs.getDouble("preco_dolar"));
            produto.put("embalagem", rs.getString("embalagem"));
            
            produtos.put(produto);
        }
        
        out.print(produtos.toString());
        
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