#!/usr/bin/env python
# coding: utf-8

# In[1]:


from pathlib import Path

Path("Final_ShinyApp").mkdir(parents = True, exist_ok = True)


# In[2]:


get_ipython().run_cell_magic('writefile', 'Final_ShinyApp/app.py', '# -*- coding: utf-8 -*-\n\nimport matplotlib.pyplot as plt\nfrom shiny import App, render, ui, reactive\nimport numpy as np\nimport joblib\nimport pandas as pd\nfrom sklearn.linear_model import LinearRegression\nfrom sklearn.ensemble import RandomForestRegressor\nfrom sklearn.ensemble import GradientBoostingRegressor\nfrom sklearn.preprocessing import MinMaxScaler\n\n\n\n# UI section starts from here \napp_ui = ui.page_fluid(\n    ui.markdown(\n        """\n        ## Climate Disease model Shiny Web App\n        """\n    ),\n    ui.layout_sidebar(\n        ui.panel_sidebar(ui.input_numeric("tavg", "average temperature", value=100),\n                         ui.input_numeric("tmax", "max temperature", value=100),\n                         ui.input_numeric("tmin", "min temperature", value=100),\n                         ui.input_numeric("pcp", "precipitation level", value=100),\n                         ui.input_action_button("btn", "Predict"),\n                         \n                         ui.input_slider("n", "N", 0, 100, 20)\n                         ),\n        \n        ui.panel_main(ui.markdown(\n        """\n        ## Linear Model Output\n        """\n    ),\n                    ui.output_text_verbatim("txt1", placeholder=True),ui.markdown(\n        """\n        ## Random Forest Model Output\n        """\n    ),\n                    ui.output_text_verbatim("txt2", placeholder=True),\n                    ui.markdown(\n        """\n        ## Gradient Boosting Model Output\n        """\n    ),\n                    ui.output_text_verbatim("txt3", placeholder=True),ui.markdown(\n        """\n        ## Histogram of the Average Temperature\n        """\n    ),\n                    ui.output_plot("histogram"),),\n    ),\n)\n\n\n## server section -> model prediction\n\ndef server(input, output, session):\n\n    full_df = pd.read_csv("https://raw.githubusercontent.com/jortiz71/p4ds/main/full_df%20(1).csv", index_col = 0)\n    X = full_df.iloc[:,3:7]\n    y = full_df["all_cause"]\n    model1 = LinearRegression()\n    model3 = GradientBoostingRegressor()\n    model2 = RandomForestRegressor()\n    model1.fit(X, y)\n    model2.fit(X,y)\n    model3.fit(X,y)\n    # invalidated.\n    @output(id = "txt1")\n    @render.text\n    @reactive.event(input.btn)\n    def _():\n        # Input data\n\n        # getting prediction\n        testset = pd.DataFrame([[input.tavg(),input.tmax(),input.tmin(),input.pcp()]],columns=["tavg", "tmax", "tmin", "pcp"],dtype=float)\n        prediction_prob = model1.predict(testset)\n        output1 = round(prediction_prob[0])\n        pred = str(output1) + " total casualties"\n        \n        return pred\n\n    @output(id = "txt2")\n    @render.text\n    @reactive.event(input.btn)\n    def _():\n        # Input data\n\n        # getting prediction\n        testset = pd.DataFrame([[input.tavg(),input.tmax(),input.tmin(),input.pcp()]],columns=["tavg", "tmax", "tmin", "pcp"],dtype=float)\n        prediction_prob = model2.predict(testset)\n        output1 = round(prediction_prob[0])\n        pred = str(output1) + " total casualties"\n\n        \n        return pred\n\n    @output(id = "txt3")\n    @render.text\n    @reactive.event(input.btn)\n    def _():\n        # Input data\n\n        # getting prediction\n        testset = pd.DataFrame([[input.tavg(),input.tmax(),input.tmin(),input.pcp()]],columns=["tavg", "tmax", "tmin", "pcp"],dtype=float)\n        prediction_prob = model3.predict(testset)\n        output1 = round(prediction_prob[0])\n        pred = str(output1) + " total casualties"\n        return pred\n    \n    @output\n    @render.plot(alt="A histogram")\n    def histogram():\n        plt.hist((full_df[full_df[\'tavg\'] >0][\'tavg\']), color = \'orange\', bins = input.n())\n        plt.title("Frequency Distribution of Average Temperature (Fahrenheit)")\n        plt.xlabel("Average Temperature (Fahrenheit)")\n        plt.ylabel("Count")\n        plt.grid(color = "lightgrey",  linewidth = 0.5)\n \n\napp = App(app_ui, server)\n')


# In[ ]:


get_ipython().system('shiny run --reload Final_ShinyApp/app.py')


# In[ ]:




