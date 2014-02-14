class DiamondsController < ApplicationController

  def index
    @search_params = params[:search] ? search_params : nil
    @search = Diamond.new(@search_params)
    @diamonds = Diamond.search(@search_params).paginate(:per_page => (params[:per_page] || 25), :page => params[:page])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diamond
      @diamond = Diamond.find(params[:id])
    end

    def search_params
      params.require(:search).permit(:shape, :size, :color, :clarity, :cut, :polish, :sym, :flour, :sort_by)
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def diamond_params
      params.require(:diamond).permit(:shape, :size, :color, :clarity, :cut, :polish, :sym, :flour, :number_of_results, :rap_percentage, :sort_by)
    end
end
