<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Alteraçao de Produto</title>
    </head>
    <body>
        <%
            int c;
            c = Integer.parseInt(request.getParameter("codigo"));
            Connection conecta;
            PreparedStatement st;
            Class.forName("org.mariadb.jdbc.Driver");
            conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
            st = conecta.prepareStatement("SELECT * FROM produto WHERE codigo = ?");
            st.setInt(1,c);
            ResultSet resultado = st.executeQuery();
            if (!resultado.next() ) {
                out.print("Este produto nao esta cadastrado");
            } else {
        %>
        <form method ="post" action="alterar_produtos.jsp">
            <p>
                <label for="codigo">Código:</label>
                <input type="number" name="codigo" id="codigo"value="<%= resultado.getString("codigo") %>"  readonly>
            </p>
            <p>
                <label for="nome">Nome do Produto:</label>
                <input type="text" name="nome" id="nome"value="<%= resultado.getString("nome")%> ">
            </p>
            <p>
                <label for="marca">Marca:</label>
                <input type="text" name="marca" id="marca"value="<%= resultado.getString("marca")%> ">
            <p>
                <label for="preco">Preço:</label>
                <input type="number" step="0.01" name="preco" id="preco"value="<%= resultado.getString("preco") %>" >
            </p>
            <p>
                <label for="codigo_barbearia">Codigo Barbearia:</label>
                <input type="number" name="codigo_barbearia" id="codigo_barbearia"value="<%= resultado.getString("codigo_barbearia") %>" >
            </p>
            <p>
                <label for="barbearia">barbearia:</label>
                <input type="number" name="barbearia" id="barbearia"value="<%= resultado.getString("barbearia") %>" >
            </p>
            <p>
                <label for="ml">ML:</label>
                <input type="number" name="ml" id="ml"value="<%= resultado.getString("ml") %>" >
            </p>
            <p>
                <label for="saldo_minimo">Saldo minimo:</label>
                <input type="number" name="saldo_minimo" id="saldo_minimo"value="<%= resultado.getString("saldo_minimo") %>" >
            </p>
            <p>
                <label for="lista_preco">Lista Preço:</label>
                <input type="number" name="lista_preco" id="lista_preco"value="<%= resultado.getString("lista_preco") %>" >
            </p>
            <p>
                <label for="embalagem">Embalagem:</label>
                <input type="number" name="embalagem" id="embalagem"value="<%= resultado.getString("embalagem") %>" >
            </p>
            <p>
                <label for="premio_barber">Premio Barbearia:</label>
                <input type="number" name="premio_barber" id="premio_barber"value="<%= resultado.getString("premio_barber") %>" >
            </p>
            <p>
                <label for="codigo_fornecedor">Codigo fornecedor:</label>
                <input type="text" name="codigo_fornecedor" id="codigo_fornecedor"value="<%= resultado.getString("codigo_fornecedor")%> ">
            </p>
            <p>
                <label for="genero">Genero:</label>
                <input type="text" name="genero" id="genero"value="<%= resultado.getString("genero")%> ">
            </p>
            <p>
                <label for="ativo">Ativo:</label>
                <input type="text" name="ativo" id="ativo"value="<%= resultado.getString("ativo")%> ">
            </p>
            <p>
                <label for="fornecedor">Fornecedor:</label>
                <input type="text" name="fornecedor" id="fornecedor"value="<%= resultado.getString("fornecedor")%> ">
            </p>
            <p>
                <label for="preco_de_custo">Preço de custo:</label>
                <input type="number" step="0.01" name="preco_de_custo" id="preco_de_custo"value="<%= resultado.getString("preco_de_custo") %>" >
            </p>
            <p>
                <label for="preco_dolar">Preço em Dolar:</label>
                <input type="number" step="0.01" name="preco_dolar" id="preco_dolar"value="<%= resultado.getString("preco_dolar") %>" >
            </p>
            <p>
                <input type="submit" value="Salvar Alteraçoes"><!-- comment -->
            </p>
            
        </form>        
        <%
            }
        %>   
    </body>
</html>
