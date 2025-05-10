<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lista de Produtos</title>
        <link rel="stylesheet" href="tabela.css"/>
        <style>
            table {
                width: 100%;
                border-collapse: collapse;
                margin: 20px 0;
                font-size: 0.9em;
                font-family: sans-serif;
                box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
            }
            table th {
                background-color: #009879;
                color: #ffffff;
                text-align: left;
                padding: 12px 15px;
            }
            table td {
                padding: 12px 15px;
                border-bottom: 1px solid #dddddd;
            }
            table tr:nth-of-type(even) {
                background-color: #f3f3f3;
            }
            table tr:last-of-type {
                border-bottom: 2px solid #009879;
            }
            table tr:hover {
                background-color: #f1f1f1;
            }
            .action-buttons a {
                display: inline-block;
                padding: 5px 10px;
                margin: 2px;
                text-decoration: none;
                color: white;
                border-radius: 3px;
                font-size: 0.8em;
            }
            .edit-btn {
                background-color: #4CAF50;
            }
            .edit-btn:hover {
                background-color: #45a049;
            }
            .search-container {
                margin: 20px 0;
            }
            .search-container input {
                padding: 8px;
                width: 300px;
            }
        </style>
    </head>
    <body>
        <h1>Lista de Produtos</h1>
        
        <div class="search-container">
            <form method="get" action="">
                <input type="text" name="search" placeholder="Pesquisar por nome ou código..." 
                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                <input type="submit" value="Buscar">
                <a href="?">Limpar busca</a>
            </form>
        </div>
        
        <%
            try {
                // Fazer a conexão
                Connection conecta;
                PreparedStatement st;
                Class.forName("org.mariadb.jdbc.Driver");
                conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
                
                // Construir a query com filtro de busca se existir
                String searchTerm = request.getParameter("search");
                String sql = "SELECT * FROM produto";
                
                if(searchTerm != null && !searchTerm.trim().isEmpty()) {
                    sql += " WHERE nome LIKE ? OR codigo LIKE ? ORDER BY nome";
                    st = conecta.prepareStatement(sql);
                    st.setString(1, "%" + searchTerm + "%");
                    st.setString(2, "%" + searchTerm + "%");
                } else {
                    sql += " ORDER BY nome";
                    st = conecta.prepareStatement(sql);
                }
                
                ResultSet rs = st.executeQuery();
        %>
                <table>
                   <thead>
                       <tr>
                         <th>Código</th>
                         <th>Nome</th>
                         <th>Marca</th>
                         <th>Preço</th>
                         <th>Preço Custo</th>
                         <th>Preço Dólar</th>
                         <th>ML</th>
                         <th>Barbearia</th>
                         <th>Cód. Barbearia</th>
                         <th>Saldo Mínimo</th>
                         <th>Lista Preço</th>
                         <th>Embalagem</th>
                         <th>Prêmio Barber</th>
                         <th>Cód. Fornecedor</th>
                         <th>Gênero</th>
                         <th>Ativo</th>
                         <th>Fornecedor</th>
                         <th>Ações</th>
                       </tr>
                   </thead>
                   <tbody>
        <%
                while (rs.next()) {
        %>
                   <tr>
                       <td><%= rs.getInt("codigo") %></td>
                       <td><%= rs.getString("nome") != null ? rs.getString("nome") : "" %></td>
                       <td><%= rs.getString("marca") != null ? rs.getString("marca") : "" %></td>
                       <td>R$ <%= String.format("%.2f", rs.getDouble("preco")) %></td>
                       <td><%= rs.getObject("preco_de_custo") != null ? "R$ " + String.format("%.2f", rs.getDouble("preco_de_custo")) : "" %></td>
                       <td><%= rs.getObject("preco_dolar") != null ? "US$ " + String.format("%.2f", rs.getDouble("preco_dolar")) : "" %></td>
                       <td><%= rs.getObject("ml") != null ? rs.getInt("ml") : "" %></td>
                       <td><%= rs.getObject("barbearia") != null ? rs.getInt("barbearia") : "" %></td>
                       <td><%= rs.getObject("codigo_barbearia") != null ? rs.getInt("codigo_barbearia") : "" %></td>
                       <td><%= rs.getObject("saldo_minimo") != null ? rs.getInt("saldo_minimo") : "" %></td>
                       <td><%= rs.getObject("lista_preco") != null ? rs.getInt("lista_preco") : "" %></td>
                       <td><%= rs.getObject("embalagem") != null ? rs.getInt("embalagem") : "" %></td>
                       <td><%= rs.getObject("premio_barber") != null ? rs.getInt("premio_barber") : "" %></td>
                       <td><%= rs.getString("codigo_fornecedor") != null ? rs.getString("codigo_fornecedor") : "" %></td>
                       <td><%= rs.getString("genero") != null ? rs.getString("genero") : "" %></td>
                       <td><%= rs.getString("ativo") != null ? rs.getString("ativo") : "" %></td>
                       <td><%= rs.getString("fornecedor") != null ? rs.getString("fornecedor") : "" %></td>
                       <td class="action-buttons">
                           <a href="carregaprod.jsp?codigo=<%=rs.getInt("codigo")%>" class="edit-btn">Alterar</a>
                       </td>
                   </tr>
        <%
                }
        %>
                   </tbody>
                </table>    
        <%
                rs.close();
                st.close();
                conecta.close();
            } catch (Exception x) {
                out.print("<div class='error-message'>Erro ao carregar produtos: " + x.getMessage() + "</div>");
            }
        %>
        
        <div style="margin-top: 20px;">
            <a href="cadastro_produto.html" style="padding: 10px 15px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 4px;">
                Cadastrar Novo Produto
            </a>
        </div>
    </body>
</html>