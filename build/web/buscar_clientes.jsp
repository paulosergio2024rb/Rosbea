<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.*"%>
<%@page contentType="application/json;charset=UTF-8" %>
<%
    String term = request.getParameter("term");
    JSONArray clientes = new JSONArray();

    if (term != null && term.length() >= 2) {
        Connection con = null;
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
            
            String sql = "SELECT rg, nome_do_cliente as nome FROM cadastro_de_clientes " +
                         "WHERE nome_do_cliente LIKE ? ORDER BY nome_do_cliente LIMIT 10";
            PreparedStatement stmt = con.prepareStatement(sql);
            stmt.setString(1, term + "%");
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject cliente = new JSONObject();
                cliente.put("rg", rs.getString("rg"));
                cliente.put("nome", rs.getString("nome"));
                clientes.put(cliente);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }
    }
    
    out.clear();
    out.print(clientes.toString());
%>