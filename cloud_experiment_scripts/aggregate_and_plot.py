#!/usr/bin/env python3
import pandas as pd, numpy as np, glob, os, matplotlib.pyplot as plt, seaborn as sns
input_pattern = "experiments/run_*/metrics_*.csv"; out_dir = "experiments/analysis"; os.makedirs(out_dir, exist_ok=True)
files = glob.glob(input_pattern)
dfs = [pd.read_csv(f).assign(source_file=os.path.basename(f)) for f in files]
df = pd.concat(dfs, ignore_index=True)
group_cols = ['run_id','F1_Ataque','F2_Recursos_VM1','F3_Coleta_Logs']
metrics = ['cpu_vm1','ram_vm1','io_vm1','cpu_vm2','ram_vm2','io_vm2','latencia_ingest_s','eventos_s']
agg_list = []
for name, group in df.groupby(group_cols):
    summary = dict(zip(group_cols, name))
    for m in metrics:
        s = group[m].astype(float)
        summary[f"{m}_p50"] = np.percentile(s.dropna(),50) if s.notna().sum()>0 else np.nan
        summary[f"{m}_p95"] = np.percentile(s.dropna(),95) if s.notna().sum()>0 else np.nan
        summary[f"{m}_p99"] = np.percentile(s.dropna(),99) if s.notna().sum()>0 else np.nan
    agg_list.append(summary)
agg_df = pd.DataFrame(agg_list); agg_df.to_csv(os.path.join(out_dir,"aggregated_runs.csv"),index=False)
plot_df = agg_df.groupby('F1_Ataque')['latencia_ingest_s_p95'].median().reset_index()
plt.figure(figsize=(6,4)); plt.plot(plot_df['F1_Ataque'],plot_df['latencia_ingest_s_p95'],marker='o')
plt.title('Latência ingest p95 por intensidade de ataque'); plt.xlabel('F1_Ataque'); plt.ylabel('latencia_ingest_s_p95 (s)'); plt.grid(True); plt.tight_layout()
plt.savefig(os.path.join(out_dir,"lat_p95_by_F1.png")); plt.close()
pivot = agg_df.pivot_table(index='F1_Ataque',columns='F2_Recursos_VM1',values='eventos_s_p95',aggfunc='median')
plt.figure(figsize=(6,4)); sns.heatmap(pivot,annot=True,fmt=".1f"); plt.title('eventos_s_p95 median (F1 x F2)'); plt.tight_layout()
plt.savefig(os.path.join(out_dir,"heatmap_eventos_p95_F1_F2.png")); plt.close()
print("Análise concluída, arquivos salvos em", out_dir)
