import os
import geopandas as gbd
import pandas as pd
import matplotlib.pyplot as plt

# Set the working directory
os.chdir("your path")


# Read world map data
world = gbd.read_file(gbd.datasets.get_path('naturalearth_lowres'))

# View country names in the world GeoDataFrame
print("Country names in World GeoDataFrame:")
print(world['name'].unique())

# Read DAYLS data
gbd_data = pd.read_csv('GBD RAW DATA')

# Check DAYLS data
print(gbd_data.head())

# Merge world map data with DAYLS data
world = world.merge(gbd_data, how='left', left_on='name', right_on='country')
world = world.drop(columns=['country'])  # Remove duplicate column

# Set plot parameters
fig, ax = plt.subplots(1, 1, figsize=(20, 10))

# Hide frame and axes
ax.axis('off')

# Draw the map
world.boundary.plot(ax=ax, linewidth=0.5, edgecolor='grey')
world.plot(column='value', ax=ax, legend=True,
           legend_kwds={'label': "DAYLS Rate",
                        'orientation': "horizontal",
                        'shrink': 0.4,
                        'aspect': 20,
                        'pad': 0.08},
           cmap='RdYlBu_r',  # Use reversed Red-Yellow-Blue color map
           missing_kwds={"color": "lightgrey", "label": "No Data"})

# Adjust color bar position and size
cax = fig.get_axes()[1]
cax.set_position([0.2, 0.08, 0.6, 0.03])

# Adjust figure layout
plt.tight_layout()

# Display the figure
plt.show()