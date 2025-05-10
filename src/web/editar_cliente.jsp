<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Buscar e Editar Cliente</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
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
            padding: 30px;
        }
        
        .card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .card h2, .card h3 {
            color: var(--secondary-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .search-form {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .form-control {
            flex: 1;
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
            padding: 10px 20px;
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
        
        .btn-search {
            background-color: var(--success-color);
        }
        
        .btn-search:hover {
            background-color: #3d8b40;
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
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
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
        
        .btn-save {
            background-color: var(--success-color);
            padding: 12px 24px;
            margin-top: 20px;
        }
        
        .btn-save:hover {
            background-color: #3d8b40;
        }
        
        .search-icon {
            margin-right: 8px;
        }
        
        .two-columns {
            grid-column: span 2;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }
            
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .search-form {
                flex-direction: column;
            }
            
            .two-columns {
                grid-column: span 1;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h2><i class="fas fa-search"></i> Buscar Cliente</h2>
            <form method="get" class="search-form">
                <input type="text" name="nome" class="form-control" placeholder="Digite o nome do cliente" 
                       value="<%= request.getParameter("nome") != null ? request.getParameter("nome") : "" %>">
                <button type="submit" class="btn btn-search">
                    <i class="fas fa-search search-icon"></i>Buscar
                </button>
            </form>

            <%
                String rg = request.getParameter("rg");
                String nomeBusca = request.getParameter("nome");

                if ((rg != null && !rg.trim().equals("")) || (nomeBusca != null && !nomeBusca.trim().equals(""))) {
                    Connection conecta = null;
                    PreparedStatement st = null;
                    ResultSet rs = null;
                    try {
                        Class.forName("org.mariadb.jdbc.Driver");
                        conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");

                        if (rg != null && !rg.trim().equals("")) {
                            st = conecta.prepareStatement("SELECT * FROM cadastro_de_clientes WHERE rg = ?");
                            st.setString(1, rg);
                        } else {
                            st = conecta.prepareStatement("SELECT * FROM cadastro_de_clientes WHERE nome_do_cliente LIKE ?");
                            st.setString(1, "%" + nomeBusca + "%");
                        }

                        rs = st.executeQuery();

                        if (rs.next()) {
            %>
            <div class="card" style="margin-top: 30px;">
                <h3><i class="fas fa-user-edit"></i> Editar Dados do Cliente</h3>
                <form method="post" action="salvar_edicao.jsp">
                    <input type="hidden" name="rg" value="<%= rs.getString("rg") %>">
                    <div class="form-grid">
                        <!-- Dados Pessoais -->
                        <div class="form-group two-columns">
                            <h4 style="color: var(--primary-color); margin-bottom: 10px;">Dados Pessoais</h4>
                        </div>
                        
                        <div class="form-group">
                            <label for="rg">RG</label>
                            <input type="text" id="rg" name="rg" class="form-control" 
                                   value="<%= rs.getString("rg") %>" readonly>
                        </div>
                        
                        <div class="form-group">
                            <label for="data_de_abertura">Data de Abertura</label>
                            <input type="date" id="data_de_abertura" name="data_de_abertura" class="form-control" 
                                   value="<%= rs.getString("data_de_abertura") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="nome_do_cliente">Nome do Cliente</label>
                            <input type="text" id="nome_do_cliente" name="nome_do_cliente" class="form-control" 
                                   value="<%= rs.getString("nome_do_cliente") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="responsavel">Responsável</label>
                            <input type="text" id="responsavel" name="responsavel" class="form-control" 
                                   value="<%= rs.getString("responsavel") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="tipo_cliente">Tipo de Cliente</label>
                            <input type="text" id="tipo_cliente" name="tipo_cliente" class="form-control" 
                                   value="<%= rs.getString("tipo_cliente") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="cpf">CPF</label>
                            <input type="text" id="cpf" name="cpf" class="form-control" 
                                   value="<%= rs.getString("cpf") %>">
                        </div>
                        
                        <!-- Endereço -->
                        <div class="form-group two-columns">
                            <h4 style="color: var(--primary-color); margin-bottom: 10px;">Endereço</h4>
                        </div>
                        
                        <div class="form-group">
                            <label for="direcao">Direção</label>
                            <input type="text" id="direcao" name="direcao" class="form-control" 
                                   value="<%= rs.getString("direcao") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="nr">Número</label>
                            <input type="text" id="nr" name="nr" class="form-control" 
                                   value="<%= rs.getString("nr") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="com">Complemento</label>
                            <input type="text" id="com" name="com" class="form-control" 
                                   value="<%= rs.getString("com") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="barrio">Bairro</label>
                            <input type="text" id="barrio" name="barrio" class="form-control" 
                                   value="<%= rs.getString("barrio") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="cidade">Cidade</label>
                            <input type="text" id="cidade" name="cidade" class="form-control" 
                                   value="<%= rs.getString("cidade") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="cep">CEP</label>
                            <input type="text" id="cep" name="cep" class="form-control" 
                                   value="<%= rs.getString("cep") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="endereco">Endereço</label>
                            <input type="text" id="endereco" name="endereco" class="form-control" 
                                   value="<%= rs.getString("endereco") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="numr">Número</label>
                            <input type="text" id="numr" name="numr" class="form-control" 
                                   value="<%= rs.getString("numr") %>">
                        </div>
                        
                        <!-- Contato -->
                        <div class="form-group two-columns">
                            <h4 style="color: var(--primary-color); margin-bottom: 10px;">Contato</h4>
                        </div>
                        
                        <div class="form-group">
                            <label for="tel_fijo">Telefone Fixo</label>
                            <input type="text" id="tel_fijo" name="tel_fijo" class="form-control" 
                                   value="<%= rs.getString("tel_fijo") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="tel_cel">Telefone Celular</label>
                            <input type="text" id="tel_cel" name="tel_cel" class="form-control" 
                                   value="<%= rs.getString("tel_cel") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" class="form-control" 
                                   value="<%= rs.getString("email") %>">
                        </div>
                        
                        <!-- Outras Informações -->
                        <div class="form-group two-columns">
                            <h4 style="color: var(--primary-color); margin-bottom: 10px;">Outras Informações</h4>
                        </div>
                        
                        <div class="form-group">
                            <label for="loja">Loja</label>
                            <input type="text" id="loja" name="loja" class="form-control" 
                                   value="<%= rs.getString("loja") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="negado">Negado</label>
                            <input type="text" id="negado" name="negado" class="form-control" 
                                   value="<%= rs.getString("negado") %>">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-save">
                        <i class="fas fa-save"></i> Salvar Alterações
                    </button>
                </form>
            </div>
            <%
                        } else {
                            out.print("<div class='alert alert-error'><i class='fas fa-exclamation-circle'></i> Cliente não encontrado</div>");
                        }
                    } catch (Exception e) {
                        out.print("<div class='alert alert-error'><i class='fas fa-exclamation-circle'></i> Erro: " + e.getMessage() + "</div>");
                    } finally {
                        if (rs != null) rs.close();
                        if (st != null) st.close();
                        if (conecta != null) conecta.close();
                    }
                }
            %>
        </div>
    </div>
</body>
</html>