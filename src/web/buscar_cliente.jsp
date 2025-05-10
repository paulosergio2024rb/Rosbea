<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String nome = request.getParameter("nome");
    if (nome == null || nome.trim().isEmpty()) return;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        Connection conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
        PreparedStatement st = conecta.prepareStatement("SELECT rg, nome_do_cliente FROM cadastro_de_clientes WHERE nome_do_cliente LIKE ? LIMIT 10");
        st.setString(1, nome + "%");

        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            String rg = rs.getString("rg");
            String nomeCliente = rs.getString("nome_do_cliente");
%>
            <div class="sugestao" onclick="carregarCliente('<%= rg %>')">
                <%= nomeCliente %> (RG: <%= rg %>)
            </div>
<%
        }
        rs.close();
        st.close();
        conecta.close();
    } catch (Exception e) {
        out.print("Erro: " + e.getMessage());
    }
%>
