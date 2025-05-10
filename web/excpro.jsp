<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Excluir produto</title>
    </head>
    <body>
        <%
            int cod;
            cod = Integer.parseInt(request.getParameter("codigo"));
        try{  
            Class.forName("org.mariadb.jdbc.Driver");
            Connection conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea","paulo","6421");
            PreparedStatement st = conecta.prepareStatement("DELETE FROM produto WHERE codigo=?");
            st.setInt(1,cod);
            int resultado = st.executeUpdate();
            if(resultado == 0){
               out.print("Produto nao cadastrado");
            } else{
              out.print("Produto do codigo " + cod + " excluido com sucesso");
            }
        } catch(Exception erro){
            String mensagemErro = erro.getMessage();
            out.print("Entre em contato com o suporte e informe o erro " + mensagemErro);
        }            
        %>            
    </body>
</html>
