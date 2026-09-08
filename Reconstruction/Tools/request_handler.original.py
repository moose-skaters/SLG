"""
Request Handler for RenderDoc MCP Bridge
Routes incoming requests to appropriate facade methods.
"""

import traceback

from .utils.export_game_routing import (
    SMART_EXPORT_BLOCKED_FOR_ENDFIELD,
    annotate_export_result,
    normalize_capture_game,
)


class RequestHandler:
    """Handles incoming MCP bridge requests"""

    def __init__(self, facade):
        self.facade = facade
        self._methods = {
            "ping": self._handle_ping,
            "get_capture_status": self._handle_get_capture_status,
            "get_draw_calls": self._handle_get_draw_calls,
            "get_frame_summary": self._handle_get_frame_summary,
            "find_draws_by_shader": self._handle_find_draws_by_shader,
            "find_draws_by_texture": self._handle_find_draws_by_texture,
            "find_draws_by_resource": self._handle_find_draws_by_resource,
            "get_draw_call_details": self._handle_get_draw_call_details,
            "get_action_timings": self._handle_get_action_timings,
            "get_shader_info": self._handle_get_shader_info,
            "apply_shader_replacement": self._handle_apply_shader_replacement,
            "remove_shader_replacement": self._handle_remove_shader_replacement,
            "debug_visualize_vec3": self._handle_debug_visualize_vec3,
            "get_buffer_contents": self._handle_get_buffer_contents,
            "get_texture_info": self._handle_get_texture_info,
            "get_texture_data": self._handle_get_texture_data,
            "get_pipeline_state": self._handle_get_pipeline_state,
            "get_fragment_output_state": self._handle_get_fragment_output_state,
            "export_textures_at_event_png": self._handle_export_textures_at_event_png,
            "export_texture_as_png": self._handle_export_texture_as_png,
            "export_texture_as_exr": self._handle_export_texture_as_exr,
            "list_captures": self._handle_list_captures,
            "open_capture": self._handle_open_capture,
            "export_fbx": self._handle_export_fbx,
            "get_mesh_attributes": self._handle_get_mesh_attributes,
            "smart_export_fbx": self._handle_smart_export_fbx,
        }

    def handle(self, request):
        """Handle a request and return response"""
        request_id = request.get("id")
        method = request.get("method")
        params = request.get("params", {})

        try:
            if method not in self._methods:
                return self._error_response(
                    request_id, -32601, "Method not found: %s" % method
                )

            result = self._methods[method](params)
            return {"id": request_id, "result": result}

        except ValueError as e:
            return self._error_response(request_id, -32602, str(e))
        except Exception as e:
            traceback.print_exc()
            return self._error_response(request_id, -32000, str(e))

    def _error_response(self, request_id, code, message):
        """Create an error response"""
        return {"id": request_id, "error": {"code": code, "message": message}}

    def _handle_ping(self, params):
        """Handle ping request"""
        return {
            "status": "ok",
            "message": "pong",
            "bridge": {
                "export_fbx_params": {
                    "capture_game": (
                        "Optional. \"genshin\" / \"原神\" | \"endfield\" / \"终末地\" | omit. "
                        "Annotates logs; Endfield should use export_fbx with explicit modes."
                    ),
                },
                "smart_export_fbx_params": {
                    "capture_game": (
                        "Optional. \"genshin\" / \"原神\" | \"endfield\" / \"终末地\" | omit. "
                        "If endfield, this tool returns an error — use export_fbx instead."
                    ),
                },
            },
        }

    def _handle_get_capture_status(self, params):
        """Handle get_capture_status request"""
        return self.facade.get_capture_status()

    def _handle_get_draw_calls(self, params):
        """Handle get_draw_calls request"""
        include_children = params.get("include_children", True)
        marker_filter = params.get("marker_filter")
        exclude_markers = params.get("exclude_markers")
        event_id_min = params.get("event_id_min")
        event_id_max = params.get("event_id_max")
        only_actions = params.get("only_actions", False)
        flags_filter = params.get("flags_filter")
        return self.facade.get_draw_calls(
            include_children=include_children,
            marker_filter=marker_filter,
            exclude_markers=exclude_markers,
            event_id_min=event_id_min,
            event_id_max=event_id_max,
            only_actions=only_actions,
            flags_filter=flags_filter,
        )

    def _handle_get_frame_summary(self, params):
        """Handle get_frame_summary request"""
        return self.facade.get_frame_summary()

    def _handle_find_draws_by_shader(self, params):
        """Handle find_draws_by_shader request"""
        shader_name = params.get("shader_name")
        if shader_name is None:
            raise ValueError("shader_name is required")
        stage = params.get("stage")
        return self.facade.find_draws_by_shader(shader_name, stage)

    def _handle_find_draws_by_texture(self, params):
        """Handle find_draws_by_texture request"""
        texture_name = params.get("texture_name")
        if texture_name is None:
            raise ValueError("texture_name is required")
        return self.facade.find_draws_by_texture(texture_name)

    def _handle_find_draws_by_resource(self, params):
        """Handle find_draws_by_resource request"""
        resource_id = params.get("resource_id")
        if resource_id is None:
            raise ValueError("resource_id is required")
        return self.facade.find_draws_by_resource(resource_id)

    def _handle_get_draw_call_details(self, params):
        """Handle get_draw_call_details request"""
        event_id = params.get("event_id")
        if event_id is None:
            raise ValueError("event_id is required")
        return self.facade.get_draw_call_details(int(event_id))

    def _handle_get_action_timings(self, params):
        """Handle get_action_timings request"""
        event_ids = params.get("event_ids")
        marker_filter = params.get("marker_filter")
        exclude_markers = params.get("exclude_markers")
        return self.facade.get_action_timings(
            event_ids=event_ids,
            marker_filter=marker_filter,
            exclude_markers=exclude_markers,
        )

    def _handle_get_shader_info(self, params):
        """Handle get_shader_info request"""
        event_id = params.get("event_id")
        stage = params.get("stage")
        if event_id is None:
            raise ValueError("event_id is required")
        if stage is None:
            raise ValueError("stage is required")
        large_text_mode = params.get("large_text_mode")
        include_constant_buffers = params.get("include_constant_buffers", True)
        return self.facade.get_shader_info(
            int(event_id),
            stage,
            large_text_mode=large_text_mode,
            include_constant_buffers=bool(include_constant_buffers),
        )

    def _handle_apply_shader_replacement(self, params):
        """Compile and apply shader replacement at pipeline stage (like Apply changes)."""
        event_id = params.get("event_id")
        stage = params.get("stage")
        source = params.get("source")
        if event_id is None:
            raise ValueError("event_id is required")
        if stage is None:
            raise ValueError("stage is required")
        if source is None:
            raise ValueError("source is required (full shader text)")
        entry_point = params.get("entry_point")
        encoding = params.get("encoding")
        compile_flags = params.get("compile_flags")
        return self.facade.apply_shader_replacement(
            int(event_id),
            stage,
            source,
            entry_point=entry_point,
            encoding=encoding,
            compile_flags=compile_flags,
        )

    def _handle_remove_shader_replacement(self, params):
        """Remove shader resource replacement."""
        resource_id = params.get("resource_id")
        if resource_id is None:
            raise ValueError("resource_id is required (original shader id from get_shader_info)")
        return self.facade.remove_shader_replacement(resource_id)

    def _handle_debug_visualize_vec3(self, params):
        """Fetch GLSL, inject vec3 debug on RT0, compile and apply in one call."""
        event_id = params.get("event_id")
        if event_id is None:
            raise ValueError("event_id is required")
        vec3_expr = params.get("vec3_expr", "_1952")
        stage = params.get("stage", "pixel")
        return self.facade.debug_visualize_vec3(int(event_id), vec3_expr, stage)

    def _handle_get_buffer_contents(self, params):
        """Handle get_buffer_contents request"""
        resource_id = params.get("resource_id")
        if resource_id is None:
            raise ValueError("resource_id is required")
        offset = params.get("offset", 0)
        length = params.get("length", 0)
        return self.facade.get_buffer_contents(resource_id, offset, length)

    def _handle_get_texture_info(self, params):
        """Handle get_texture_info request"""
        resource_id = params.get("resource_id")
        if resource_id is None:
            raise ValueError("resource_id is required")
        return self.facade.get_texture_info(resource_id)

    def _handle_get_texture_data(self, params):
        """Handle get_texture_data request"""
        resource_id = params.get("resource_id")
        if resource_id is None:
            raise ValueError("resource_id is required")
        mip = params.get("mip", 0)
        slice_idx = params.get("slice", 0)
        sample = params.get("sample", 0)
        depth_slice = params.get("depth_slice")  # None = full volume
        return self.facade.get_texture_data(resource_id, mip, slice_idx, sample, depth_slice)

    def _handle_get_pipeline_state(self, params):
        """Handle get_pipeline_state request"""
        event_id = params.get("event_id")
        if event_id is None:
            raise ValueError("event_id is required")
        return self.facade.get_pipeline_state(int(event_id))

    def _handle_get_fragment_output_state(self, params):
        """Handle get_fragment_output_state request"""
        event_id = params.get("event_id")
        if event_id is None:
            raise ValueError("event_id is required")
        return self.facade.get_fragment_output_state(int(event_id))

    def _handle_export_textures_at_event_png(self, params):
        """Handle export_textures_at_event_png request"""
        event_id = params.get("event_id")
        if event_id is None:
            raise ValueError("event_id is required")
        return self.facade.export_textures_at_event_png(
            int(event_id),
            output_directory=params.get("output_directory"),
            include_srv=params.get("include_srv", True),
            include_uav=params.get("include_uav", True),
            include_rt=params.get("include_rt", True),
            include_depth=params.get("include_depth", True),
            dedupe=params.get("dedupe", True),
            resource_ids=params.get("resource_ids"),
        )

    def _handle_export_texture_as_png(self, params):
        """Handle export_texture_as_png request"""
        event_id = params.get("event_id")
        resource_id = params.get("resource_id")
        if event_id is None:
            raise ValueError("event_id is required")
        if resource_id is None:
            raise ValueError("resource_id is required")
        return self.facade.export_texture_as_png(
            int(event_id),
            resource_id,
            mip=params.get("mip", 0),
            slice_index=params.get("slice_index", 0),
            output_directory=params.get("output_directory"),
            filename=params.get("filename"),
        )

    def _handle_export_texture_as_exr(self, params):
        """Handle export_texture_as_exr request"""
        event_id = params.get("event_id")
        resource_id = params.get("resource_id")
        output_directory = params.get("output_directory")
        if event_id is None:
            raise ValueError("event_id is required")
        if resource_id is None:
            raise ValueError("resource_id is required")
        if output_directory is None:
            raise ValueError("output_directory is required")
        return self.facade.export_texture_as_exr(
            int(event_id),
            resource_id,
            output_directory,
            filename=params.get("filename"),
            mip=params.get("mip", 0),
            slice_index=params.get("slice_index", 0),
            sample_index=params.get("sample_index", 0),
        )

    def _handle_list_captures(self, params):
        """Handle list_captures request"""
        directory = params.get("directory")
        if directory is None:
            raise ValueError("directory is required")
        return self.facade.list_captures(directory)

    def _handle_open_capture(self, params):
        """Handle open_capture request"""
        capture_path = params.get("capture_path")
        if capture_path is None:
            raise ValueError("capture_path is required")
        return self.facade.open_capture(capture_path)

    def _handle_export_fbx(self, params):
        """Handle export_fbx request"""
        from_eid = params.get("from_eid")
        to_eid = params.get("to_eid")
        save_path = params.get("save_path")
        if from_eid is None:
            raise ValueError("from_eid is required")
        if to_eid is None:
            raise ValueError("to_eid is required")
        if save_path is None:
            raise ValueError("save_path is required")

        mode = (params.get("world_position_mode") or "postvs_attribute").strip()
        if mode not in ("postvs_attribute", "clip_inverse_vp", "vertex_instance_matrix"):
            raise ValueError(
                'world_position_mode must be "postvs_attribute", "clip_inverse_vp", '
                'or "vertex_instance_matrix"'
            )

        ws = params.get("ws_output_attr")
        n_out = params.get("normal_output_attr")

        if mode == "postvs_attribute":
            if ws is None or ws == "" or ws == "None":
                raise ValueError(
                    "ws_output_attr is required when world_position_mode is postvs_attribute "
                    "(VS output used as world-space positions; see get_mesh_attributes)"
                )
            if n_out is None or n_out == "" or n_out == "None":
                raise ValueError(
                    "normal_output_attr is required for postvs_attribute "
                    "(VS output with normals in the same space as ws_output_attr), "
                    "or use world_position_mode clip_inverse_vp with vertex-buffer normals only."
                )
        elif mode == "vertex_instance_matrix":
            icb = params.get("instance_model_cbuffer_name")
            if icb is None or str(icb).strip() in ("", "None"):
                raise ValueError(
                    "instance_model_cbuffer_name is required when world_position_mode is "
                    "vertex_instance_matrix"
                )
            itmpl = params.get("instance_model_matrix_path_template")
            if itmpl is None or str(itmpl).strip() in ("", "None"):
                raise ValueError(
                    "instance_model_matrix_path_template is required when world_position_mode is "
                    "vertex_instance_matrix"
                )
            if ws in ("", "None"):
                ws = None
        else:
            if ws in ("", "None"):
                ws = None
            if n_out in ("", "None"):
                n_out = None

        kwargs = {}
        for key in (
            "pos_attr",
            "uv0_attr",
            "normal_attr",
            "vcolor_attr",
            "uv_output_attr",
            "normal_output_attr",
            "vcolor_output_attr",
            "tangent_attr",
            "tangent_output_attr",
            "sv_pos_attr",
        ):
            if params.get(key) is not None:
                kwargs[key] = params[key]
        if params.get("is_reverse_normal") is not None:
            kwargs["is_reverse_normal"] = bool(params["is_reverse_normal"])
        if params.get("fix_unity_coord") is not None:
            kwargs["fix_unity_coord"] = bool(params["fix_unity_coord"])
        if params.get("is_export_texture") is not None:
            kwargs["is_export_texture"] = bool(params["is_export_texture"])
        if params.get("is_single") is not None:
            kwargs["is_single"] = bool(params["is_single"])
        if params.get("vp_matrix") is not None:
            kwargs["vp_matrix"] = params["vp_matrix"]
        if params.get("vp_cbuffer_name") is not None:
            kwargs["vp_cbuffer_name"] = params["vp_cbuffer_name"]
        if params.get("vp_var_names") is not None:
            kwargs["vp_var_names"] = params["vp_var_names"]
        kwargs["ws_output_attr"] = ws
        kwargs["world_position_mode"] = mode
        if params.get("clip_output_attr") is not None:
            kwargs["clip_output_attr"] = params["clip_output_attr"]
        if params.get("vp_ubo_columns") is not None:
            kwargs["vp_ubo_columns"] = bool(params["vp_ubo_columns"])
        if params.get("instance_model_cbuffer_name") is not None:
            kwargs["instance_model_cbuffer_name"] = params["instance_model_cbuffer_name"]
        if params.get("instance_model_matrix_path_template") is not None:
            kwargs["instance_model_matrix_path_template"] = params[
                "instance_model_matrix_path_template"
            ]
        if params.get("instance_model_ubo_columns") is not None:
            kwargs["instance_model_ubo_columns"] = bool(params["instance_model_ubo_columns"])
        if params.get("instance_model_transform_kind") is not None:
            kwargs["instance_model_transform_kind"] = params["instance_model_transform_kind"]
        if params.get("instance_mhy_world_offset_cbuffer_name") is not None:
            kwargs["instance_mhy_world_offset_cbuffer_name"] = params[
                "instance_mhy_world_offset_cbuffer_name"
            ]
        if params.get("instance_mhy_world_offset_var") is not None:
            kwargs["instance_mhy_world_offset_var"] = params["instance_mhy_world_offset_var"]

        capture_game = normalize_capture_game(params.get("capture_game"))
        data = self.facade.export_fbx(int(from_eid), int(to_eid), save_path, **kwargs)
        return annotate_export_result(data, capture_game, "export_fbx")

    def _handle_smart_export_fbx(self, params):
        """Handle smart_export_fbx request — auto-detects extraction mode per EID."""
        from_eid = params.get("from_eid")
        to_eid = params.get("to_eid")
        save_path = params.get("save_path")
        if from_eid is None:
            raise ValueError("from_eid is required")
        if to_eid is None:
            raise ValueError("to_eid is required")
        if save_path is None:
            raise ValueError("save_path is required")

        capture_game = normalize_capture_game(params.get("capture_game"))
        if capture_game == "endfield":
            raise ValueError(SMART_EXPORT_BLOCKED_FOR_ENDFIELD)

        kwargs = {}
        for key in (
            "model_matrix_cbuffer_name",
            "model_matrix_var_name",
            "instance_offset_cbuffer_name",
            "instance_offset_var_template",
            "pos_attr",
            "uv0_attr",
            "normal_attr",
            "vcolor_attr",
            "tangent_attr",
        ):
            if params.get(key) is not None:
                kwargs[key] = params[key]

        for bool_key in (
            "model_matrix_ubo_columns",
            "instance_model_ubo_columns",
            "fix_unity_coord",
            "is_reverse_normal",
        ):
            if params.get(bool_key) is not None:
                kwargs[bool_key] = bool(params[bool_key])
        if params.get("is_single") is not None:
            kwargs["is_single"] = bool(params["is_single"])

        if params.get("instance_stride_bytes") is not None:
            kwargs["instance_stride_bytes"] = int(params["instance_stride_bytes"])

        data = self.facade.smart_export_fbx(int(from_eid), int(to_eid), save_path, **kwargs)
        return annotate_export_result(data, capture_game, "smart_export_fbx")

    def _handle_get_mesh_attributes(self, params):
        """Handle get_mesh_attributes request"""
        event_id = params.get("event_id")
        if event_id is None:
            raise ValueError("event_id is required")
        return self.facade.get_mesh_attributes(int(event_id))
