<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
String query = request.getParameter("query");
Connection conn = null;

try {
    Class.forName("org.mariadb.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

    String sql = "SELECT endereco, bairro, cidade, cep FROM cadastro_de_ruas WHERE endereco LIKE ? LIMIT 10";
    PreparedStatement pst = conn.prepareStatement(sql);
    pst.setString(1, query + "%");
    ResultSet rs = pst.executeQuery();
%>
    <ul style="background: white; border: 1px solid #ccc; list-style: none; padding: 5px; position: absolute; width: 100%; max-height: 150px; overflow-y: auto; z-index: 10;">
<%
    while (rs.next()) {
        String endereco = rs.getString("endereco");
        String bairro = rs.getString("bairro");
        String cidade = rs.getString("cidade");
        String cep = rs.getString("cep");
%>
        <li style="padding: 5px; cursor: pointer;" onclick="selecionarEndereco('<%= endereco %>', '<%= bairro %>', '<%= cidade %>', '<%= cep %>')">
            <%= endereco %> - <%= bairro %>, <%= cidade %> (<%= cep %>)
        </li>
<%
    }
    rs.close();
    pst.close();
    conn.close();
%>
    </ul>
<%
} catch (Exception e) {
    out.print("Erro: " + e.getMessage());
}
%>
