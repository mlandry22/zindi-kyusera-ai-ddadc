* start repo!
* add all notebooks
  * DONE
    * munging, JPG
    * munging, adjust training images
    * gradio public HF space
  * ADD
    * munging: zoom left/right
    * munging: all processes to pick up and combine/calculate files
    * munging: athena process for CSV to counts
  * FIX 
    * Loop through all three VLM notebooks to get files in same format as VLLM
    * Get precise VLLM prompt (posted)
    * Parsing function from prompt to text
* full process
  * script to run everything in proper order
  * libraries and hardware used
  * R scripts used to submit: final ensemble + "all_subs" creation, if separate (should be the same)

h2ogpt settings
```
    # fixed defaults
    document_subset = "Relevant"
    document_choice = "All"
    max_time = 360
    max_new_tokens = settings.max_new_tokens
    min_max_new_tokens = settings.min_max_new_tokens
    do_sample = False  # will be auto-enabled below (or by remote h2ogpt if was still False) if temp > 0 or top_p < 1 or top_k > 1
    seed = 0
    temperature = 0.0
    top_k = 1
    top_p = 0.99999  # for TGI, 1.0 is not allowed
    num_beams = 1
    visible_models = llm
    assert isinstance(
        visible_models, str
    ), f"visible_models must be string, but is {visible_models}"
    pre_prompt_extraction = pre_prompt_summary
    prompt_extraction = prompt_summary
    visible_vision_models = [settings.default_vision_model]
```
