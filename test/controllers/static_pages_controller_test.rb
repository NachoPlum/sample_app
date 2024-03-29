require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    #DRY
    #Crea la variable base_title con el string que se repite
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  test "should get root" do
    get root_path
    assert_response :success
  end

  test "should get home" do
    #Verifica que exista la pagina llamada
    get root_path
    #Corrobora que haya una respuesta exitosa 200 en el server
    assert_response :success
    #Corrobora que el tag title tenga la palabra correcta
    assert_select "title", "#{@base_title}"
  end

  test "should get help" do
    get help_path
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

  test "should get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | #{@base_title}"
  end

end
