%%%-------------------------------------------------------------------
%%% @author egobrain <egobrain@linux-ympb>
%%% @copyright (C) 2012, egobrain
%%% @doc
%%%  Orm Compiler is rebar plugin for compiling models from config to
%%% valid erlang file. Based on configs.
%%%
%%% Global options: declaration:
%%%   dip_orm_config
%%%
%%% Avaible Global options:
%%%   configs_folder: folder where configs are stored.
%%%                   Default: "priv/models/"
%%%
%%%   output_src_folder: folder where to put result sources.
%%%                   Default: "src"
%%%                      
%%%
%%% @end
%%% Created : 22 Nov 2012 by egobrain <egobrain@linux-ympb>
%%%-------------------------------------------------------------------
-module(dip_orm_compiler).

-include("log.hrl").
-include("apps/rebar/include/rebar.hrl").

-compile({parse_transform,do}).
-compile({parse_transform,cut}).

-export ([models/2]).

%% ===================================================================
%%% API
%% ===================================================================

models(RebarConfig,_AppFile) ->
    Config = element(3,RebarConfig),
    do([error_m ||
	   GlobalConfig <- dip_orm_configs:get_global_config(Config),
	   RawModels <- dip_orm_configs:get_db_model_config(Config),
	   Models <- dip_utils:success_map(
			       dip_orm_configs:get_config(_,GlobalConfig),
			       RawModels),
	   Models2 <- dip_orm_configs:fill_links(Models),
	   fold(dip_orm_model_file:write(_,GlobalConfig),Models2),
	   fold(dip_orm_dip_model_file:write(_,GlobalConfig),Models2),
	   dip_orm_config_file:write(dip_orm,Models2,GlobalConfig)
	  ]).
    
%% ===================================================================
%%% Internal Logic
%% ===================================================================


fold(_,[]) -> ok;
fold(F,[H|T]) ->
    case F(H) of
	ok -> fold(F,T);
	Err -> Err
    end.

    

%% ===================================================================
%%% Internal functions
%% ===================================================================
