class GraphsController < ApplicationController
  before_filter :login_required
  before_filter :check_auth_delegated

  # GET /graphs
  # GET /graphs.xml
  def index
    @graphs = current_user.graphs

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /graphs/1
  # GET /graphs/1.xml
  def show
    @graph = Graph.find(params[:id], :user_id => current_user.id)

    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  # GET /graphs/new
  # GET /graphs/new.xml
  def new
    @graph = Graph.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /graphs/1/edit
  def edit
    @graph = Graph.find(params[:id], :user_id => current_user.id)
  end

  # POST /graphs
  # POST /graphs.xml
  def create
    @graph = Graph.new(params[:graph].merge(:user_id => current_user.id))

    # Catch any errors coming from saving the graph, and show error case.
    # This is specifically to catch unauthorized errors from the SEOmoz API.
    status = begin
      @graph.save
    rescue
      false
    end

    respond_to do |format|
      if status
        flash[:notice] = 'Graph was successfully created.'
        format.html { redirect_to(@graph) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /graphs/1
  # PUT /graphs/1.xml
  def update
    @graph = Graph.find(params[:id], :user_id => current_user.id)

    respond_to do |format|
      if @graph.update_attributes(params[:graph])
        flash[:notice] = 'Graph was successfully updated.'
        format.html { redirect_to(@graph) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /graphs/1
  # DELETE /graphs/1.xml
  def destroy
    @graph = Graph.find(params[:id], :user_id => current_user.id)
    @graph.destroy

    respond_to do |format|
      format.html { redirect_to(graphs_url) }
    end
  end
end
