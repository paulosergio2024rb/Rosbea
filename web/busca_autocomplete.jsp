<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%
    String termo = request.getParameter("term");
    JSONArray lista = new JSONArray();
    
    if (termo != null && termo.trim().length() >= 2) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

            String sql = "SELECT rg, nome_do_cliente FROM cadastro_de_clientes WHERE nome_do_cliente LIKE ? ORDER BY nome_do_cliente LIMIT 10";
            ps = con.prepareStatement(sql);
            ps.setString(1, "%" + termo + "%");

            rs = ps.executeQuery();
            
            while (rs.next()) {
                JSONObject cliente = new JSONObject();
                cliente.put("label", rs.getString("nome_do_cliente") + " (RG: " + rs.getString("rg") + ")");
                cliente.put("value", rs.getString("nome_do_cliente"));
                lista.add(cliente);
            }
            
        } catch (Exception e) {
            JSONObject erro = new JSONObject();
            erro.put("error", e.getMessage());
            lista.add(erro);
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
    
    out.print(lista.toJSONString());
    out.flush();
%>