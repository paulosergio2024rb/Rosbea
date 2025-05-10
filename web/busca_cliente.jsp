<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Buscar Cliente</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.13.2/themes/base/jquery-ui.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4a6fa5;
            --secondary-color: #166088;
            --accent-color: #4fc3f7;
            --success-color: #4caf50;
            --warning-color: #ffc107;
            --error-color: #f44336;
            --light-gray: #f5f5f5;
            --medium-gray: #e0e0e0;
            --dark-gray: #757575;
            --purple-color: #9c27b0;
        }
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Roboto', sans-serif;
        }
        
        body {
            background-color: #f9f9f9;
            color: #333;
            line-height: 1.6;
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        h2, h3 {
            color: var(--purple-color);
            margin: 20px 0 15px;
        }
        
        .search-form {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .form-group {
            margin-bottom: 15px;
            position: relative;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }
        
        input[type="text"] {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid var(--medium-gray);
            border-radius: 4px;
            font-size: 16px;
            transition: border 0.3s;
        }
        
        input[type="text"]:focus {
            border-color: var(--purple-color);
            outline: none;
        }
        
        .btn {
            display: inline-block;
            background-color: var(--purple-color);
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: background-color 0.3s;
            width: 200px; /* Largura fixa para ambos os botões */
            text-align: center;
        }
        
        .btn:hover {
            background-color: #7b1fa2;
        }
        
        .btn-warning {
            background-color: var(--warning-color);
            color: #000;
        }
        
        .btn-warning:hover {
            background-color: #e0a800;
        }
        
        .btn-container {
            display: flex;
            gap: 10px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9em;
            margin: 25px 0;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        
        table thead tr {
            background-color: var(--purple-color);
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
            border-bottom: 2px solid var(--purple-color);
        }
        
        table tbody tr:hover {
            background-color: rgba(156, 39, 176, 0.1);
        }
        
        .no-results {
            background: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            color: var(--dark-gray);
            font-style: italic;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .error-message {
            background-color: #fde8e8;
            color: var(--error-color);
            padding: 15px;
            border-radius: 4px;
            margin: 15px 0;
            border-left: 4px solid var(--error-color);
        }
        
        .ui-autocomplete {
            max-height: 200px;
            overflow-y: auto;
            overflow-x: hidden;
            background-color: white;
            border: 1px solid var(--medium-gray);
            border-radius: 0 0 4px 4px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .ui-menu-item {
            padding: 8px 15px;
            cursor: pointer;
            border-bottom: 1px solid var(--light-gray);
        }
        
        .ui-menu-item:hover {
            background-color: var(--light-gray);
        }
        
        .ui-helper-hidden-accessible {
            display: none;
        }
        
        @media (max-width: 768px) {
            table {
                font-size: 0.8em;
            }
            
            table th, table td {
                padding: 8px 10px;
            }
            
            .btn-container {
                flex-direction: column;
            }
            
            .btn {
                width: 100%; /* Botões ocupam toda a largura em mobile */
            }
        }
    </style>
</head>
<body>
    <h2><i class="fas fa-search"></i> Buscar Cliente por Nome</h2>
    <div class="search-form">
        <form method="get" id="searchForm">
            <div class="form-group">
                <label for="nome"><i class="fas fa-user"></i> Nome do Cliente</label>
                <input type="text" id="nome" name="nome" value="<%= request.getParameter("nome") != null ? request.getParameter("nome") : "" %>" placeholder="Digite o nome do cliente" />
            </div>
            <div class="btn-container">
                <button type="submit" class="btn"><i class="fas fa-search"></i> Buscar</button>
                <button type="button" id="btnEditar" class="btn btn-warning" onclick="editarClienteSelecionado()" <%= request.getParameter("nome") == null ? "disabled" : "" %>>
                    <i class="fas fa-edit"></i> Editar Cliente Selecionado
                </button>
            </div>
        </form>
    </div>

<%
    String nomeBusca = request.getParameter("nome");

    if (nomeBusca != null && !nomeBusca.trim().equals("")) {
        Connection conecta = null;
        PreparedStatement st = null;
        ResultSet rs = null;
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

            st = conecta.prepareStatement("SELECT * FROM cadastro_de_clientes WHERE nome_do_cliente LIKE ?");
            st.setString(1, "%" + nomeBusca + "%");

            rs = st.executeQuery();

            boolean encontrouRegistros = false;
            
            // Tabela de resultados da busca
            out.print("<h3><i class='fas fa-list'></i> Resultados da Busca</h3>");
            out.print("<div class='table-responsive'>");
            out.print("<table>");
            out.print("<thead>");
            out.print("<tr>");
            out.print("<th><i class='fas fa-id-card'></i> RG</th>");
            out.print("<th><i class='fas fa-user'></i> Nome</th>");
            out.print("<th><i class='fas fa-user-tie'></i> Responsável</th>");
            out.print("<th><i class='fas fa-tag'></i> Tipo</th>");
            out.print("<th><i class='fas fa-city'></i> Cidade</th>");
            out.print("<th><i class='fas fa-envelope'></i> Email</th>");
            out.print("</tr>");
            out.print("</thead>");
            out.print("<tbody>");
            
            while (rs.next()) {
                encontrouRegistros = true;
%>
                <tr>
                    <td><%= rs.getString("rg") %></td>
                    <td><%= rs.getString("nome_do_cliente") %></td>
                    <td><%= rs.getString("responsavel") != null ? rs.getString("responsavel") : "-" %></td>
                    <td><%= rs.getString("tipo_cliente") %></td>
                    <td><%= rs.getString("cidade") %></td>
                    <td><%= rs.getString("email") != null ? rs.getString("email") : "-" %></td>
                </tr>
<%
            }
            
            out.print("</tbody>");
            out.print("</table>");
            out.print("</div>");

            if (!encontrouRegistros) {
                out.print("<div class='no-results'>");
                out.print("<i class='fas fa-info-circle' style='font-size: 24px; margin-bottom: 10px;'></i>");
                out.print("<p>Nenhum cliente encontrado com os critérios de busca</p>");
                out.print("</div>");
            }

        } catch (Exception e) {
            out.print("<div class='error-message'>");
            out.print("<i class='fas fa-exclamation-circle'></i> <strong>Erro:</strong> " + e.getMessage());
            out.print("</div>");
        } finally {
            if (rs != null) rs.close();
            if (st != null) st.close();
            if (conecta != null) conecta.close();
        }
    }
%>

<!-- Adicionando scripts para o autocomplete -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<script>
$(function() {
    // Carrega todos os nomes de clientes uma vez quando a página é carregada
    var clientes = [];
    
    // Esta função simularia uma chamada ao servidor
    function carregarClientes() {
        <%
        Connection conecta = null;
        PreparedStatement st = null;
        ResultSet rs = null;
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
            st = conecta.prepareStatement("SELECT nome_do_cliente FROM cadastro_de_clientes");
            rs = st.executeQuery();
            while (rs.next()) {
                String nome = rs.getString("nome_do_cliente").replace("\"", "\\\"");
        %>
                clientes.push("<%= nome %>");
        <%
            }
        } catch (Exception e) {
            System.out.println("Erro ao carregar clientes: " + e.getMessage());
        } finally {
            if (rs != null) rs.close();
            if (st != null) st.close();
            if (conecta != null) conecta.close();
        }
        %>
    }
    
    carregarClientes();
    
    // Configura o autocomplete com os dados carregados
    $("#nome").autocomplete({
        source: clientes,
        minLength: 2
    });
    
    // Atualiza o estado do botão de edição quando o campo de nome muda
    $("#nome").on("input", function() {
        var nomeCliente = $(this).val();
        if (nomeCliente && nomeCliente.trim() !== "") {
            $("#btnEditar").prop("disabled", false);
        } else {
            $("#btnEditar").prop("disabled", true);
        }
    });
});

function editarClienteSelecionado() {
    var nomeCliente = $("#nome").val();
    if (nomeCliente && nomeCliente.trim() !== "") {
        window.location.href = "editar_cliente.jsp?nome=" + encodeURIComponent(nomeCliente);
    }
}
</script>
</body>
</html>