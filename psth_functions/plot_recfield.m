function [] = plot_recfield(current_neuron,event_first,event_last,event_threshold,event_onset,unit_figure,pre_time,bin_size)

                            %% Plots elements from rec field analysis
                            figure(unit_figure);
                            hold on
                            if  event_first>0                                
                                %red label                   
                                psth_bar=bar(event_first:bin_size:event_last,current_neuron(((event_first + abs(pre_time)) / bin_size):((event_last + abs(pre_time)) / bin_size)),'BarWidth', 1);
                                set(psth_bar,'FaceColor','r');
                                set(psth_bar, 'EdgeAlpha', 0);
                                
                                plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                                line([event_first event_first], ylim, 'Color', 'red', 'LineWidth', 0.75);
                                line([event_last event_last], ylim, 'Color', 'red', 'LineWidth', 0.75);
                                line([event_onset event_onset], ylim, 'Color', 'black', 'LineWidth', 0.75);                                
                            else
                                plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                                line([event_onset event_onset], ylim, 'Color', 'black', 'LineWidth', 0.75);                                
                            end
                            hold off
end