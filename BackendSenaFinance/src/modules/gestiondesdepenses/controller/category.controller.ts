import { Request, Response } from 'express';
import { ValidationError } from 'class-validator';
import { myDataSource } from '../../../configs/data-source';
import { generateServerErrorCode, success } from '../../../configs/response';
import { checkRelationsOneToMany } from '../../../configs/checkRelationsOneToManyBeforDelete';
import { paginationAndRechercheInit } from '../../../configs/paginationAndRechercheInit';
import { Category } from '../entity/category.entity';

// ====================== CREATE ======================
export const createCategory = async (req: Request, res: Response) => {
  try {
    const categoryRepository = myDataSource.getRepository(Category);
    const category = categoryRepository.create(req.body as Partial<Category>);
    const savedCategory = (await categoryRepository.save(category)) as Category;

    const message = `La catégorie "${savedCategory.name}" a bien été créée.`;
    return success(res, 201, savedCategory, message);
  } catch (error: any) {
    if (error instanceof ValidationError) {
      return generateServerErrorCode(
        res,
        400,
        error,
        'Les données de la catégorie sont invalides.'
      );
    }

    if (error.code === 'ER_DUP_ENTRY' || error.code === '23505') {
      return generateServerErrorCode(
        res,
        400,
        error,
        'Une catégorie avec ce nom existe déjà.'
      );
    }

    return generateServerErrorCode(
      res,
      500,
      error,
      "La catégorie n'a pas pu être ajoutée. Réessayez dans quelques instants."
    );
  }
};

// ====================== GET ALL ======================
export const getAllCategories = async (req: Request, res: Response) => {
  try {
    const categories = await myDataSource.getRepository(Category).find({
      order: { name: 'ASC' },
    });

    const message = 'La liste des catégories a bien été récupérée.';
    return success(res, 200, categories, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La liste des catégories n'a pas pu être récupérée. Réessayez dans quelques instants."
    );
  }
};

// ====================== PAGINATED ======================
export const getCategoriesPaginated = async (req: Request, res: Response) => {
  try {
    const { limit, searchTerm, startIndex } = paginationAndRechercheInit(
      req,
      Category
    );

    let query = myDataSource
      .getRepository(Category)
      .createQueryBuilder('c');

    if (searchTerm) {
      query = query.where(
        '( c.name ILIKE :keyword OR c.description ILIKE :keyword )',
        { keyword: `%${searchTerm}%` }
      );
    }

    const [data, totalElements] = await query
      .orderBy('c.id', 'DESC')
      .skip(startIndex)
      .take(limit)
      .getManyAndCount();

    const totalPages = Math.ceil(totalElements / limit);
    const message = 'La liste des catégories a bien été récupérée.';

    return success(
      res,
      200,
      { data, totalPages, totalElements, limit },
      message
    );
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "Erreur lors de la récupération paginée des catégories."
    );
  }
};

// ====================== GET BY ID ======================
export const getCategoryById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const category = await myDataSource.getRepository(Category).findOne({
      where: { id: id as any },
    });

    if (!category) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "La catégorie demandée n'existe pas."
      );
    }

    const message = 'La catégorie a bien été trouvée.';
    return success(res, 200, category, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La catégorie n'a pas pu être récupérée. Réessayez dans quelques instants."
    );
  }
};

// ====================== UPDATE ======================
export const updateCategory = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const categoryRepository = myDataSource.getRepository(Category);

    const category = await categoryRepository.findOne({
      where: { id: id as any },
    });

    if (!category) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "Cette catégorie n'existe pas."
      );
    }

    categoryRepository.merge(category, req.body);
    const updatedCategory = await categoryRepository.save(category);

    const message = `La catégorie "${updatedCategory.name}" a bien été modifiée.`;
    return success(res, 200, updatedCategory, message);
  } catch (error: any) {
    if (
      error instanceof ValidationError ||
      error.code === 'ER_DUP_ENTRY' ||
      error.code === '23505'
    ) {
      return generateServerErrorCode(
        res,
        400,
        error,
        'Une catégorie avec ce nom existe déjà.'
      );
    }

    return generateServerErrorCode(
      res,
      500,
      error,
      "La catégorie n'a pas pu être modifiée. Réessayez dans quelques instants."
    );
  }
};

// ====================== DELETE ======================
export const deleteCategory = async (req: Request, res: Response) => {
  try {
    const id = req.params.id;

    const categoryRepository = myDataSource.getRepository(Category);
    const category = await categoryRepository.findOne({
      where: { id: id as any },
    });

    if (!category) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "La catégorie demandée n'existe pas."
      );
    }

    const hasRelations = await checkRelationsOneToMany('Category', id);
    if (hasRelations) {
      return generateServerErrorCode(
        res,
        400,
        'Relations existantes',
        'La catégorie est liée à des dépenses et ne peut pas être supprimée.'
      );
    }

    await categoryRepository.remove(category);

    const message = `La catégorie "${category.name}" a bien été supprimée.`;
    return success(res, 200, category, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La catégorie n'a pas pu être supprimée. Réessayez dans quelques instants."
    );
  }
};