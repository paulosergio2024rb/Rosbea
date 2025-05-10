<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Lista de Clientes</title>
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
                padding: 20px;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 20px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }

            h1 {
                color: var(--secondary-color);
                margin-bottom: 20px;
                padding-bottom: 10px;
                border-bottom: 1px solid var(--medium-gray);
            }

            .table-container {
                overflow-x: auto;
                margin: 25px 0;
            }

            table {
                width: 100%;
                border-collapse: collapse;
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
                vertical-align: middle; /* Alinhamento vertical centralizado */
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

            .btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                background-color: var(--primary-color);
                color: white;
                padding: 6px 12px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 13px;
                font-weight: 500;
                text-align: center;
                transition: background-color 0.3s;
                text-decoration: none;
                height: 30px; /* Altura fixa para os botões */
            }

            .btn:hover {
                background-color: var(--secondary-color);
            }

            .btn-add {
                background-color: var(--success-color);
                margin-top: 20px;
                padding: 10px 20px;
                font-size: 14px;
            }

            .btn-add:hover {
                background-color: #3d8b40;
            }

            .btn-edit {
                background-color: #ffc107;
                color: #212529;
            }

            .btn-edit:hover {
                background-color: #e0a800;
                color: #212529;
            }

            .btn-delete {
                background-color: var(--error-color);
                margin-left: 8px;
            }

            .btn-delete:hover {
                background-color: #d32f2f;
            }

            .action-buttons {
                display: flex;
                justify-content: flex-start;
                align-items: center;
            }

            .alert {
                padding: 15px;
                margin-bottom: 20px;
                border-radius: 4px;
            }

            .alert-error {
                background-color: #f2dede;
                color: #a94442;
                border: 1px solid #ebccd1;
            }

            .search-container {
                margin-bottom: 20px;
                display: flex;
                gap: 10px;
            }

            .search-input {
                flex: 1;
                padding: 10px 15px;
                border: 1px solid var(--medium-gray);
                border-radius: 4px;
                font-size: 16px;
            }

            .search-btn {
                background-color: var(--primary-color);
                color: white;
                border: none;
                border-radius: 4px;
                padding: 10px 20px;
                cursor: pointer;
            }

            @media (max-width: 768px) {
                .container {
                    padding: 15px;
                }

                .search-container {
                    flex-direction: column;
                }

                .action-buttons {
                    flex-direction: column;
                    gap: 5px;
                }

                .btn-delete {
                    margin-left: 0;
                }
            }
        </style>
    </head>
    <a href="gerenciar_clientes.html"></i> Voltar</a> 
<body>
    <div class="container">
        <h1><i class="fas fa-users"></i> Clientes Cadastrados</h1>

        <div class="search-container">
            <input type="text" class="search-input" placeholder="Pesquisar cliente...">
            <button class="search-btn"><i class="fas fa-search"></i> Buscar</button>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>RG</th>
                        <th>Nome</th>
                        <th>Cidade</th>
                        <th>Email</th>
                        <th>Telefone</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("org.mariadb.jdbc.Driver");
                            Connection con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery("SELECT rg, nome_do_cliente, cidade, email, tel_cel FROM cadastro_de_clientes ORDER BY nome_do_cliente");

                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("rg")%></td>
                        <td><%= rs.getString("nome_do_cliente")%></td>
                        <td><%= rs.getString("cidade")%></td>
                        <td><%= rs.getString("email")%></td>
                        <td><%= rs.getString("tel_cel")%></td>
                    </tr>
                    <%
                        }
                        rs.close();
                        st.close();
                        con.close();
                    } catch (Exception e) {
                    %>
                    <tr>
                        <td colspan="5" class="alert alert-error">
                            <i class="fas fa-exclamation-circle"></i> Erro ao carregar clientes: <%= e.getMessage()%>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>

        <a href="cadastrar_cliente.jsp" class="btn btn-add">
            <i class="fas fa-plus-circle"></i> Novo Cliente
        </a>
    </div>

    <script>
        // Função simples de busca na tabela
        document.querySelector('.search-input').addEventListener('input', function () {
            const searchTerm = this.value.toLowerCase();
            const rows = document.querySelectorAll('table tbody tr');

            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        });
    </script>
</body>
</html>