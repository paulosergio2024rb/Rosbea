<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.ArrayList, java.util.List" %>

<%-- Declaração da classe Usuario --%>
<%!
    public class Usuario {
        private int id;
        private String nomeUsuario;

        public Usuario(int id, String nomeUsuario) {
            this.id = id;
            this.nomeUsuario = nomeUsuario;
        }

        public int getId() {
            return id;
        }

        public String getNomeUsuario() {
            return nomeUsuario;
        }
    }
%>

<%-- Conexão com o banco de dados e obtenção dos usuários --%>
<%
    // Configurações do banco de dados
    final String DB_URL = "jdbc:mariadb://localhost:3306/Rosbea";
    final String DB_USER = "paulo";
    final String DB_PASSWORD = "6421";
    
    List<Usuario> listaDeUsuarios = new ArrayList<>();
    String mensagemErro = null;

    // Usando try-with-resources para garantir o fechamento automático dos recursos
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT id, nome_usuario FROM usuarios")) {
            
            while (rs.next()) {
                listaDeUsuarios.add(new Usuario(
                    rs.getInt("id"),
                    rs.getString("nome_usuario")
                ));
            }
        }
    } catch (ClassNotFoundException e) {
        mensagemErro = "Driver do banco de dados não encontrado: " + e.getMessage();
        e.printStackTrace();
    } catch (SQLException e) {
        mensagemErro = "Erro ao acessar o banco de dados: " + e.getMessage();
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lista de Usuários</title>
    <style>
        :root {
            --primary-color: #007bff;
            --danger-color: #dc3545;
            --danger-hover: #c82333;
            --light-gray: #f4f4f4;
            --lighter-gray: #f9f9f9;
            --border-gray: #ddd;
            --text-color: #333;
            --white: #fff;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light-gray);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            line-height: 1.6;
        }

        .container {
            background-color: var(--white);
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            width: 90%;
            max-width: 1000px;
            margin: 2rem 0;
        }

        h1 {
            text-align: center;
            color: var(--text-color);
            margin-bottom: 1.5rem;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 1.5rem 0;
            font-size: 0.9rem;
        }

        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-gray);
        }

        th {
            background-color: var(--lighter-gray);
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.8rem;
            letter-spacing: 0.5px;
        }

        tr:hover {
            background-color: rgba(0, 123, 255, 0.05);
        }

        .actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .btn {
            padding: 6px 12px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-edit {
            color: var(--primary-color);
            border: 1px solid var(--primary-color);
            background-color: transparent;
        }

        .btn-edit:hover {
            background-color: rgba(0, 123, 255, 0.1);
            text-decoration: none;
        }

        .btn-delete {
            background-color: var(--danger-color);
            color: var(--white);
            border: 1px solid var(--danger-color);
        }

        .btn-delete:hover {
            background-color: var(--danger-hover);
            border-color: var(--danger-hover);
        }

        .empty-state {
            text-align: center;
            padding: 2rem;
            color: #666;
            font-style: italic;
        }

        .error-message {
            color: var(--danger-color);
            font-weight: 500;
            padding: 1rem;
            text-align: center;
            background-color: rgba(220, 53, 69, 0.1);
            border-radius: 4px;
            margin: 1rem 0;
        }

        .footer {
            margin-top: 1rem;
            text-align: center;
        }

        .footer a {
            color: var(--primary-color);
            text-decoration: none;
        }

        .footer a:hover {
            text-decoration: underline;
        }

        @media (max-width: 768px) {
            .container {
                padding: 1rem;
                width: 95%;
            }
            
            th, td {
                padding: 8px 10px;
            }
            
            .actions {
                flex-direction: column;
                gap: 5px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Lista de Usuários</h1>

        <% if (mensagemErro != null) { %>
            <div class="error-message">
                <%= mensagemErro %>
            </div>
        <% } else if (listaDeUsuarios.isEmpty()) { %>
            <div class="empty-state">
                Nenhum usuário cadastrado no sistema.
            </div>
        <% } else { %>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nome de Usuário</th>
                        <th>Ações</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Usuario usuario : listaDeUsuarios) { %>
                        <tr>
                            <td><%= usuario.getId() %></td>
                            <td><%= usuario.getNomeUsuario() %></td>
                            <td class="actions">
                                <a href="editar_usuario.jsp?id=<%= usuario.getId() %>" 
                                   class="btn btn-edit">
                                    Editar
                                </a>
                                <form action="excluir_usuario.jsp" method="post" style="display: inline;">
                                    <input type="hidden" name="id" value="<%= usuario.getId() %>">
                                    <button type="submit" 
                                            class="btn btn-delete"
                                            onclick="return confirm('Tem certeza que deseja excluir este usuário?')">
                                        Excluir
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>

    <div class="footer">
        <a href="painel_admin.jsp">
            <i class="fas fa-arrow-left"></i> Voltar ao Painel de Administração
        </a>
    </div>
</body>
</html>