<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Alteração de Produto</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1976d2;
            --secondary-color: #0d47a1;
            --accent-color: #4fc3f7;
            --warning-color: #ff9800;
            --light-gray: #f5f5f5;
            --medium-gray: #e0e0e0;
            --dark-gray: #757575;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f9f9f9;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .form-container {
            background: white;
            padding: 30px;
            max-width: 700px;
            width: 100%;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        h1 {
            font-size: 1.8rem;
            color: var(--primary-color);
            margin-bottom: 25px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        form {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        label {
            font-weight: 500;
            color: var(--secondary-color);
            margin-bottom: 5px;
            display: block;
        }

        input[type="text"],
        input[type="number"] {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid var(--medium-gray);
            border-radius: 4px;
            font-size: 1rem;
        }

        input[type="submit"] {
            background-color: var(--primary-color);
            color: white;
            padding: 12px;
            border: none;
            border-radius: 4px;
            font-size: 1rem;
            cursor: pointer;
            transition: 0.3s;
        }

        input[type="submit"]:hover {
            background-color: var(--secondary-color);
        }

        .message {
            padding: 15px;
            background-color: #fff3cd;
            border-left: 5px solid #ffa000;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 1rem;
            color: #856404;
        }
    </style>
</head>
<body>
    <div class="form-container">
        <h1><i class="fas fa-edit"></i> Alterar Produto</h1>
        <%
            int c;
            c = Integer.parseInt(request.getParameter("codigo"));
            Connection conecta;
            PreparedStatement st;
            Class.forName("org.mariadb.jdbc.Driver");
            conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
            st = conecta.prepareStatement("SELECT * FROM produto WHERE codigo = ?");
            st.setInt(1,c);
            ResultSet resultado = st.executeQuery();
            if (!resultado.next() ) {
        %>
            <div class="message">Este produto não está cadastrado.</div>
        <%
            } else {
        %>
        <form method="post" action="alterar_produtos.jsp">
            <label for="codigo">Código:</label>
            <input type="number" name="codigo" id="codigo" value="<%= resultado.getString("codigo") %>" readonly>

            <label for="nome">Nome do Produto:</label>
            <input type="text" name="nome" id="nome" value="<%= resultado.getString("nome") %>">

            <label for="inspirado">Inspirado:</label>
            <input type="text" name="marca" id="marca" value="<%= resultado.getString("marca") %>">

            <label for="preco">Preço:</label>
            <input type="number" step="0.01" name="preco" id="preco" value="<%= resultado.getString("preco") %>">

            <label for="codigo_barbearia">Código Barbearia:</label>
            <input type="number" name="codigo_barbearia" id="codigo_barbearia" value="<%= resultado.getString("codigo_barbearia") %>">

            <label for="barbearia">Barbearia:</label>
            <input type="number" name="barbearia" id="barbearia" value="<%= resultado.getString("barbearia") %>">

            <label for="ml">ML:</label>
            <input type="number" name="ml" id="ml" value="<%= resultado.getString("ml") %>">

            <label for="saldo_minimo">Saldo Mínimo:</label>
            <input type="number" name="saldo_minimo" id="saldo_minimo" value="<%= resultado.getString("saldo_minimo") %>">

            <label for="lista_preco">Lista Preço:</label>
            <input type="number" name="lista_preco" id="lista_preco" value="<%= resultado.getString("lista_preco") %>">

            <label for="embalagem">Embalagem:</label>
            <input type="number" name="embalagem" id="embalagem" value="<%= resultado.getString("embalagem") %>">

            <label for="premio_barber">Prêmio Barbearia:</label>
            <input type="number" name="premio_barber" id="premio_barber" value="<%= resultado.getString("premio_barber") %>">

            <label for="codigo_fornecedor">Código Fornecedor:</label>
            <input type="text" name="codigo_fornecedor" id="codigo_fornecedor" value="<%= resultado.getString("codigo_fornecedor") %>">

            <label for="genero">Gênero:</label>
            <input type="text" name="genero" id="genero" value="<%= resultado.getString("genero") %>">

            <label for="ativo">Ativo:</label>
            <input type="text" name="ativo" id="ativo" value="<%= resultado.getString("ativo") %>">

            <label for="fornecedor">Fornecedor:</label>
            <input type="text" name="fornecedor" id="fornecedor" value="<%= resultado.getString("fornecedor") %>">

            <label for="preco_de_custo">Preço de Custo:</label>
            <input type="number" step="0.01" name="preco_de_custo" id="preco_de_custo" value="<%= resultado.getString("preco_de_custo") %>">

            <label for="preco_dolar">Preço em Dólar:</label>
            <input type="number" step="0.01" name="preco_dolar" id="preco_dolar" value="<%= resultado.getString("preco_dolar") %>">

            <input type="submit" value="Salvar Alterações">
        </form>
        <%
            }
        %>
    </div>
</body>
</html>
