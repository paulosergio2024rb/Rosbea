<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cadastro de Cliente</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4a6fa5;
            --secondary-color: #166088;
            --accent-color: #4fc3f7;
            --success-color: #4caf50;
            --error-color: #f44336;
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
            line-height: 1.6;
            color: #333;
            background-color: #f9f9f9;
            padding: 0;
            margin: 0;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            background-color: var(--primary-color);
            color: white;
            padding: 20px 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        header h1 {
            text-align: center;
            font-weight: 500;
        }
        
        .card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 25px;
            margin-bottom: 30px;
        }
        
        .card h2 {
            color: var(--secondary-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: var(--secondary-color);
        }
        
        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid var(--medium-gray);
            border-radius: 4px;
            font-size: 16px;
            transition: border 0.3s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--accent-color);
            box-shadow: 0 0 0 2px rgba(79, 195, 247, 0.2);
        }
        
        .btn {
            display: inline-block;
            background-color: var(--primary-color);
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            text-align: center;
            transition: background-color 0.3s;
            text-decoration: none;
        }
        
        .btn:hover {
            background-color: var(--secondary-color);
        }
        
        .btn-block {
            display: block;
            width: 100%;
        }
        
        .table-responsive {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 25px 0;
            font-size: 0.9em;
            min-width: 600px;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        
        table thead tr {
            background-color: var(--primary-color);
            color: white;
            text-align: left;
        }
        
        table th, table td {
            padding: 12px 15px;
        }
        
        table tbody tr {
            border-bottom: 1px solid var(--medium-gray);
        }
        
        table tbody tr:nth-of-type(even) {
            background-color: var(--light-gray);
        }
        
        table tbody tr:last-of-type {
            border-bottom: 2px solid var(--primary-color);
        }
        
        table tbody tr:hover {
            background-color: rgba(79, 195, 247, 0.1);
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .alert-success {
            background-color: #dff0d8;
            color: #3c763d;
            border: 1px solid #d6e9c6;
        }
        
        .alert-error {
            background-color: #f2dede;
            color: #a94442;
            border: 1px solid #ebccd1;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .btn-sm {
            padding: 5px 10px;
            font-size: 14px;
        }
        
        .btn-edit {
            background-color: #ffc107;
        }
        
        .btn-edit:hover {
            background-color: #e0a800;
        }
        
        .btn-delete {
            background-color: var(--error-color);
        }
        
        .btn-delete:hover {
            background-color: #d32f2f;
        }
        
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .container {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>Sistema de Cadastro de Clientes</h1>
        </div>
    </header>
    
    <div class="container">
        <div class="card">
            <h2>Cadastrar Novo Cliente</h2>
            <form method="post">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="rg">RG*</label>
                        <input type="text" id="rg" name="rg" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="data_de_abertura">Data de Abertura*</label>
                        <input type="date" id="data_de_abertura" name="data_de_abertura" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="nome_do_cliente">Nome do Cliente</label>
                        <input type="text" id="nome_do_cliente" name="nome_do_cliente" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="responsavel">Responsável</label>
                        <input type="text" id="responsavel" name="responsavel" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="tipo_cliente">Tipo de Cliente</label>
                        <input type="text" id="tipo_cliente" name="tipo_cliente" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="direcao">Direção</label>
                        <input type="text" id="direcao" name="direcao" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="nr">Número</label>
                        <input type="text" id="nr" name="nr" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="com">Complemento</label>
                        <input type="text" id="com" name="com" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="barrio">Bairro</label>
                        <input type="text" id="barrio" name="barrio" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="tel_fijo">Telefone Fixo</label>
                        <input type="text" id="tel_fijo" name="tel_fijo" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="tel_cel">Telefone Celular</label>
                        <input type="text" id="tel_cel" name="tel_cel" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="cidade">Cidade</label>
                        <input type="text" id="cidade" name="cidade" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="cep">CEP</label>
                        <input type="text" id="cep" name="cep" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="cpf">CPF</label>
                        <input type="text" id="cpf" name="cpf" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="loja">Loja</label>
                        <input type="text" id="loja" name="loja" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="endereco">Endereço</label>
                        <input type="text" id="endereco" name="endereco" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="numr">Número</label>
                        <input type="text" id="numr" name="numr" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="negado">Negado</label>
                        <input type="text" id="negado" name="negado" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" class="form-control">
                    </div>
                </div>
                
                <button type="submit" class="btn btn-block">Cadastrar Cliente</button>
            </form>
        </div>

        <%
            Connection conecta = null;
            try {
                Class.forName("org.mariadb.jdbc.Driver");
                conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");

                if (request.getMethod().equalsIgnoreCase("post")) {
                    String sql = "INSERT INTO cadastro_de_clientes VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                    PreparedStatement st = conecta.prepareStatement(sql);
                    st.setString(1, request.getParameter("rg"));
                    st.setString(2, request.getParameter("data_de_abertura"));
                    st.setString(3, request.getParameter("nome_do_cliente"));
                    st.setString(4, request.getParameter("responsavel"));
                    st.setString(5, request.getParameter("tipo_cliente"));
                    st.setString(6, request.getParameter("direcao"));
                    st.setString(7, request.getParameter("nr"));
                    st.setString(8, request.getParameter("com"));
                    st.setString(9, request.getParameter("barrio"));
                    st.setString(10, request.getParameter("tel_fijo"));
                    st.setString(11, request.getParameter("tel_cel"));
                    st.setString(12, request.getParameter("cidade"));
                    st.setString(13, request.getParameter("cep"));
                    st.setString(14, request.getParameter("cpf"));
                    st.setString(15, request.getParameter("loja"));
                    st.setString(16, request.getParameter("endereco"));
                    st.setString(17, request.getParameter("numr"));
                    st.setString(18, request.getParameter("negado"));
                    st.setString(19, request.getParameter("email"));
                    st.executeUpdate();
                    out.print("<div class='alert alert-success'>Cliente cadastrado com sucesso!</div>");
                }

                // LISTAR CLIENTES
                PreparedStatement list = conecta.prepareStatement("SELECT rg, nome_do_cliente, cidade, tel_cel, email FROM cadastro_de_clientes ORDER BY nome_do_cliente");
                ResultSet rs = list.executeQuery();
        %>

        <div class="card">
            <h2>Clientes Cadastrados</h2>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>RG</th>
                            <th>Nome</th>
                            <th>Cidade</th>
                            <th>Celular</th>
                            <th>Email</th>
                            <th>Ações</th>
                        </tr>
                    </thead>
                    <tbody>
        <%
                while (rs.next()) {
        %>
                        <tr>
                            <td><%= rs.getString("rg") %></td>
                            <td><%= rs.getString("nome_do_cliente") %></td>
                            <td><%= rs.getString("cidade") %></td>
                            <td><%= rs.getString("tel_cel") %></td>
                            <td><%= rs.getString("email") %></td>
                            <td class="action-buttons">
                                <a href="editar_cliente.jsp?rg=<%= rs.getString("rg") %>" class="btn btn-sm btn-edit">Editar</a>
                                <a href="excluir_cliente.jsp?rg=<%= rs.getString("rg") %>" class="btn btn-sm btn-delete">Excluir</a>
                            </td>
                        </tr>
        <%
                }
                rs.close();
                list.close();
                conecta.close();
            } catch (Exception e) {
                out.print("<div class='alert alert-error'>Erro: " + e.getMessage() + "</div>");
            }
        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
