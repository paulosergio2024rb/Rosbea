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
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }

        .container {
            width: 90%;
            max-width: 1200px;
            margin: 30px auto;
        }

        header {
            background-color: #007BFF;
            color: white;
            padding: 20px 0;
            text-align: center;
        }

        h1 {
            margin: 0;
        }

        .card {
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 0 5px rgba(0,0,0,0.1);
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            margin-bottom: 5px;
            font-weight: bold;
        }

        .form-control {
            padding: 10px;
            font-size: 14px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        .btn {
            background-color: #28a745;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: bold;
            text-decoration: none;
            display: inline-block;
        }

        .btn:hover {
            opacity: 0.9;
        }

        .btn-block {
            width: 100%;
            text-align: center;
        }

        .alert {
            padding: 15px;
            margin-top: 20px;
            border-radius: 4px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
        }

        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
        }
    </style>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            document.querySelector("form").addEventListener("keydown", function (e) {
                if (e.key === "Enter") {
                    e.preventDefault(); // Evita envio com Enter
                }
            });
        });

        function buscarEndereco(valor) {
            if (valor.length < 2) {
                document.getElementById("sugestoes").innerHTML = "";
                return;
            }

            fetch("buscar_enderecos.jsp?query=" + encodeURIComponent(valor))
                .then(response => response.text())
                .then(data => {
                    document.getElementById("sugestoes").innerHTML = data;
                });
        }

        function selecionarEndereco(valor, bairro, cidade, cep) {
            document.getElementById("direcao").value = valor;
            document.getElementById("barrio").value = bairro;
            document.getElementById("cidade").value = cidade;
            document.getElementById("cep").value = cep;
            document.getElementById("sugestoes").innerHTML = "";
        }
    </script>
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
                    <div class="form-group"><label for="rg">RG</label><input type="text" id="rg" name="rg" class="form-control" required></div>
                    <div class="form-group"><label for="data_de_abertura">Data de Abertura</label><input type="date" id="data_de_abertura" name="data_de_abertura" class="form-control"></div>
                    <div class="form-group"><label for="nome_do_cliente">Nome do Cliente</label><input type="text" id="nome_do_cliente" name="nome_do_cliente" class="form-control"></div>
                    <div class="form-group"><label for="responsavel">Responsável</label><input type="text" id="responsavel" name="responsavel" class="form-control"></div>
                    <div class="form-group"><label for="tipo_cliente">Tipo Cliente</label><input type="text" id="tipo_cliente" name="tipo_cliente" class="form-control"></div>
                    <div class="form-group"><label for="direcao">Direção</label><input type="text" id="direcao" name="direcao" class="form-control" autocomplete="off" onkeyup="buscarEndereco(this.value)"><div id="sugestoes" style="position: relative;"></div></div>
                    <div class="form-group"><label for="nr">NR</label><input type="text" id="nr" name="nr" class="form-control"></div>
                    <div class="form-group"><label for="com">Complemento</label><input type="text" id="com" name="com" class="form-control"></div>
                    <div class="form-group"><label for="barrio">Bairro</label><input type="text" id="barrio" name="barrio" class="form-control"></div>
                    <div class="form-group"><label for="tel_fijo">Telefone Fixo</label><input type="text" id="tel_fijo" name="tel_fijo" class="form-control"></div>
                    <div class="form-group"><label for="tel_cel">Telefone Celular</label><input type="text" id="tel_cel" name="tel_cel" class="form-control"></div>
                    <div class="form-group"><label for="cidade">Cidade</label><input type="text" id="cidade" name="cidade" class="form-control"></div>
                    <div class="form-group"><label for="cep">CEP</label><input type="text" id="cep" name="cep" class="form-control"></div>
                    <div class="form-group"><label for="cpf">CPF</label><input type="text" id="cpf" name="cpf" class="form-control"></div>
                    <div class="form-group"><label for="loja">Loja</label><input type="text" id="loja" name="loja" class="form-control"></div>
                    <div class="form-group"><label for="endereco">Endereço</label><input type="text" id="endereco" name="endereco" class="form-control"></div>
                    <div class="form-group"><label for="numr">Número</label><input type="text" id="numr" name="numr" class="form-control"></div>
                    <div class="form-group"><label for="negado">Negado</label><input type="text" id="negado" name="negado" class="form-control"></div>
                    <div class="form-group"><label for="email">E-mail</label><input type="email" id="email" name="email" class="form-control"></div>
                </div>

                <div style="display: flex; gap: 10px; margin-top: 20px;">
                    <button type="submit" class="btn btn-block" style="flex: 1;">Cadastrar Cliente</button>
                    <a href="http://localhost:8080/Rosbea/clientes.html" class="btn btn-block" style="flex: 1; background-color: #dc3545;">Voltar</a>
                </div>
            </form>

            <%
                Connection conecta = null;
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

                    if (request.getMethod().equalsIgnoreCase("post")) {
                        String rgDigitado = request.getParameter("rg");
                        String verificaRG = "SELECT COUNT(*) FROM cadastro_de_clientes WHERE rg = ?";
                        PreparedStatement ver = conecta.prepareStatement(verificaRG);
                        ver.setString(1, rgDigitado);
                        ResultSet resultado = ver.executeQuery();
                        resultado.next();
                        int total = resultado.getInt(1);
                        ver.close();
                        resultado.close();

                        if (total > 0) {
                            out.print("<div class='alert alert-error'>Erro: O RG '" + rgDigitado + "' já está cadastrado!</div>");
                        } else {
                            String sql = "INSERT INTO cadastro_de_clientes VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                            PreparedStatement st = conecta.prepareStatement(sql);
                            st.setString(1, rgDigitado);
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
                    }

                    conecta.close();
                } catch (Exception e) {
                    out.print("<div class='alert alert-error'>Erro: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
</body>
</html>
