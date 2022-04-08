%���������Ҫȥ���հױ߽���Ǹ���ͼ����Ӧ��������axis_handle
%�����������
%����Ϊm�ļ�������·��������������ͬһ�ļ���
function [ ] = Expand_axis_fill_figure( axis_handle )  %��������
% TightInset��λ��
inset_vectior = get(axis_handle, 'TightInset');
inset_x = inset_vectior(1);
inset_y = inset_vectior(2);
inset_w = inset_vectior(3);
inset_h = inset_vectior(4);

% OuterPosition��λ��
outer_vector = get(axis_handle, 'OuterPosition');
pos_new_x = outer_vector(1) + inset_x; % ��Position��ԭ���Ƶ���TightInset��ԭ��
pos_new_y = outer_vector(2) + inset_y;
pos_new_w = outer_vector(3) - inset_w - inset_x; % ����Position�Ŀ�
pos_new_h = outer_vector(4) - inset_h - inset_y; % ����Position�ĸ�

% ����Position
set(axis_handle, 'Position', [pos_new_x, pos_new_y, pos_new_w, pos_new_h]);
%��������